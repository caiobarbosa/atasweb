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
  ECS_CLUSTER="atasweb-cluster-staging"
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
	    	"image": "'$DOCKER_REGISTER/$DOCKER_IMAGE:$CIRCLE_SHA1'",
	    	"essential": true,
	    	"memory": 100,
	    	"cpu": 10,
	    	"portMappings": [
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

  if revision=$(aws ecs register-task-definition --region $ECS_REGION --cli-input-json file:///tmp/task_definition.json --family $ECS_TASK_FAMILY | \
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

stop_service(){
 echo "Stop the Service: $ECS_SERVICE"


 if [[ $(aws ecs update-service --cluster $ECS_CLUSTER --region $ECS_REGION --service $ECS_SERVICE --desired-count 0 | \
            $JQ ".service.serviceName") == "$ECS_SERVICE" ]]; then
    for attempt in {1..30}; do
      if stale=$(aws ecs describe-services --cluster $ECS_CLUSTER --region $ECS_REGION --services $ECS_SERVICE | \
                  $JQ ".services[0].deployments | .[] | select(.taskDefinition != \"$revision\") | .taskDefinition"); then
        echo "Waiting the service stops: $stale"
        sleep 5
      else
        echo "Service stopped: $ECS_SERVICE"
        return 0
      fi
    done

    echo "Stopping the service $ECS_SERVICE took too long."
    return 1
  else
    echo "Error to stop service: $ECS_SERVICE"
    return 1
 fi
}

start_service() {
  echo "Start the service: $ECS_SERVICE"

  if [[ $(aws ecs update-service --cluster $ECS_CLUSTER --region $ECS_REGION --service $ECS_SERVICE --desired-count 1 | \
            $JQ ".service.serviceName") == "$ECS_SERVICE" ]]; then


    for attempt in {1..30}; do
      if [[ $(aws ecs describe-services --cluster $ECS_CLUSTER --region $ECS_REGION --services $ECS_SERVICE | \
                  $JQ ".services[0].runningCount") == "1" ]]; then
        echo "Service started: $ECS_SERVICE"
        return 0
      else
        echo "Waiting the service starts..."
        sleep 5
      fi
    done

    echo "Starting the service $ECS_SERVICE took too long."
    return 1
  else
    echo "Error to start service: $ECS_SERVICE"
    return 1
  fi
}


restart_service() {
  if [[ $(aws ecs describe-services --cluster $ECS_CLUSTER --region $ECS_REGION --services $ECS_SERVICE | \
            $JQ '.services[0].runningCount') == "0" ]]; then
    start_service
  else
    stop_service
    start_service
  fi
}

update_service() {
  if [[ $(aws ecs update-service --cluster $ECS_CLUSTER --region $ECS_REGION --service $ECS_SERVICE --task-definition $revision | \
            $JQ '.service.taskDefinition') == "$revision" ]]; then
    echo "Service updated: $revision"
  else
    echo "Error to update service: $ECS_SERVICE"
    return 1
  fi
}

create_or_update_service() {
  if [[ $(aws ecs describe-services --cluster $ECS_CLUSTER --region $ECS_REGION --services $ECS_SERVICE | \
            $JQ '.failures | .[] | .reason') == "MISSING" ]]; then
    create_service
  else
    update_service
    restart_service
  fi
}


deploy_server() {
  create_task_definition
  create_or_update_service
}

# Deployment

deploy_image
deploy_server
