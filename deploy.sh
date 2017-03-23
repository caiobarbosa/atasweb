#!/usr/bin/env bash

JQ="jq --raw-output --exit-status"

set -e
set -u
set -o pipefail

ENVIRONMENT=$1
VERSION=$2

TAG_SUFFIX=""
ECS_REGION="us-west-2"
ECS_CLUSTER="atasweb-production"
ECS_TASK_FAMILY="$DOCKER_IMAGE-production"
ECS_SERVICE="$DOCKER_IMAGE-production"

if [ "$ENVIRONMENT" ==  "staging" ]; then
  TAG_SUFFIX="-beta"
  ECS_CLUSTER="atasweb"
  ECS_TASK_FAMILY="atasweb-task-staging"
  ECS_SERVICE="atasweb-service-staging"
fi

deploy_image() {
	eval $(aws ecr get-login --region us-west-2)
	docker push $DOCKER_REGISTER/$DOCKER_IMAGE:$CIRCLE_SHA1
}

create_task_definition() {
  task_definition='{	
	"family": "'$ECS_TASK_FAMILY'",
	"containerDefinitions": [
	   {
	    	"name": "atasweb",
	    	"image": "'$DOKCER_REGISTER/$DOCKER_IMAGE:$CIRCLE_SHA1'",
	    	"essential": true,
	    	"memory": 100,
	    	"cpu": 10,
	    	"portMappings: [
		   {
			"hostPort": 80,
			"containerPort": 80,
			"protocol": "tcp"
		   }
	    	]
	   }	
	]
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

create_service() {
  service='{
	"serviceName": "'$ECS_SERVICE'",
	"taskDefinition": "'$ECS_TASK_FAMILY'",
	"desiredCount": 1
  }'
  
  echo $service > /tmp/service.json

  if [[ $(aws ecs create-service --cluster $ECS_CLUSTER --region $ECS_REGION --service-name $ECS_SERVICE --cli-input-json file:///tmp/service.json | \
          $JQ '.service.serviceName') == "$ECS_SERVICE" ]]; then
	echo "Service created: $ECS_SERVICE"
  else
	echo "Error to create service: $ECS_SERVICE"
	return 1
  fi

}

deploy_image
create_task_definition
create_service
