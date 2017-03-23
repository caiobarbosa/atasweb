#!/usr/bin/env bash

JQ="jq --raw-output --exit-status"

set -e
set -u
set -o pipefail

ENVIRONMENT=$1
VERSION=$2

TAG_SUFFIX=""
ECS_CLUSTER="atasweb-production"
ECS_TASK_FAMILY="$DOCKER_IMAGE-production"
ECS_SERVICE="$DOCKER_IMAGE-production"

if [ "$ENVIRONMENT" ==  "staging" ]; then
  TAG_SUFFIX="-beta"
  ECS_CLUSTER="atasweb-staging"
  ECS_TASK_FAMILY="$DOCKER_IMAGE-staging"
  ECS_SERVICE="$DOCKER_IMAGE-staging"
fi

deploy_image() {
	eval $(aws ecr get-login --region us-west-2)
	docker push $DOKCER_REGISTER/$DOCKER_IMAGE:$CIRCLE_SHA1

}

create_task_definition() {
  task_definition='{
    "requirement": [
	{
	    "name": "atasweb",
	    "image": "$AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/salvus/atas:$CIRCLE_SHA1",
	    "essential": true,
	    "memory": 100,
	    "cpu": 10,
	    "portMapping": [
		{
			"hostPort": 80,
			"containerPort": 80,
			"protocol": "tcp"
		}
	    ]
	}
      ],
    "family": "'$ECS_TASK_FAMILY'"
  }'

  echo $task_definition > /tmp/task_definition.json


  if revision=$(aws ecs register-task-definition --cli-input-json file:///tmp/task_definition.json --family $ECS_TASK_FAMILY | \
                  $JQ '.taskDefinition.taskDefinitionArn'); then
    echo "Create new revision of task definition: $revision"
  else
    echo "Failed to register task definition"
    return 1
  fi

}

register_definition() {

    if revision=$(aws ecs register-task-definition --container-definitions "$task_def" --family $family | $JQ '.taskDefinition.taskDefinitionArn'); then
        echo "Revision: $revision"
    else
        echo "Failed to register task definition"
        return 1
    fi

}

deploy_cluster() {

    host_port=80
    family="atasweb-cluster"

    make_task_def
    register_definition
    if [[ $(aws ecs update-service --cluster circle-ecs-cluster --service circle-ecs-service --task-definition $revision | \
                   $JQ '.service.taskDefinition') != $revision ]]; then
        echo "Error updating service."
        return 1
    fi

    # wait for older revisions to disappear
    # not really necessary, but nice for demos
    for attempt in {1..30}; do
        if stale=$(aws ecs describe-services --cluster circle-ecs-cluster --services circle-ecs-service | \
                       $JQ ".services[0].deployments | .[] | select(.taskDefinition != \"$revision\") | .taskDefinition"); then
            echo "Waiting for stale deployments:"
            echo "$stale"
            sleep 5
        else
            echo "Deployed!"
            return 0
        fi
    done
    echo "Service update took too long."
    return 1
}

deploy_image
deploy_cluster
