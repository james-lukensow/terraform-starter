#!/bin/bash
set -ve

OUTPUT_FILE=../infrastructure/.plan/output.json
REGION=`jq -r .region.value $OUTPUT_FILE`

# Config values
ECS_REPO_NAME=`jq -r .aws_repo_api_name.value $OUTPUT_FILE`
ECS_REPO_URL=`jq -r .aws_repo_api_url.value $OUTPUT_FILE`
ECS_REPO_URL_AUTH=`jq -r .aws_repo_api_url.value $OUTPUT_FILE`
ECS_CLUSTER_NAME=`jq -r .aws_cluster_name.value $OUTPUT_FILE`
ECS_SERVICE_NAME=`jq -r .aws_service_api_name.value $OUTPUT_FILE`
TASKS_FAMILY=`jq -r .aws_ecs_api_task_family.value $OUTPUT_FILE`
AWS_ECS_EXECUTION_ROLE=`jq -r .aws_ecs_execution_role.value $OUTPUT_FILE`
LOG_LOCAL_PREFIX=`jq -r .aws_local_prefix.value $OUTPUT_FILE`
ECS_DEFINITION_CPU=`jq -r .aws_ecs_definition_cpu.value $OUTPUT_FILE`
ECS_DEFINITION_MEMORY=`jq -r .aws_ecs_definition_memory.value $OUTPUT_FILE`
SOME_CONFIG_VALUE=`jq -r .some_config.value $OUTPUT_FILE`

# Remove and create temp env file
rm -rf .env.build
cp .env.dev .env.build
echo -e "\nAPI_DOCS=$API_DOCS\nSFCC_AUTH_KEY=$SFCC_AUTH_KEY" >> .env.build

ECS_REPO_URL_AUTH=$(echo "$ECS_REPO_URL_AUTH" | sed -r 's/\/.*//g')

# Get auth
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin $ECS_REPO_URL_AUTH

# Build docker image
docker build -t $ECS_REPO_NAME .
docker tag $ECS_REPO_NAME:latest $ECS_REPO_URL:latest
docker push $ECS_REPO_URL:latest

# Create the definition file
echo "{\"executionRoleArn\":\"$AWS_ECS_EXECUTION_ROLE\",\"containerDefinitions\":[{\"name\":\"$TASKS_FAMILY\",\"image\":\"$ECS_REPO_URL:latest\",\"logConfiguration\":{\"logDriver\":\"awslogs\",\"options\":{\"awslogs-group\":\"/$LOG_LOCAL_PREFIX-api-cloudwatch\",\"awslogs-region\":\"$REGION\",\"awslogs-stream-prefix\":\"ecs\"}},\"essential\":true,\"portMappings\":[{\"containerPort\":3000,\"hostPort\":3000}]}],\"memory\":\"$ECS_DEFINITION_MEMORY\",\"networkMode\":\"awsvpc\",\"cpu\":\"$ECS_DEFINITION_CPU\",\"requiresCompatibilities\":[\"FARGATE\"]}" > tasks/definition.json

json=$(aws ecs register-task-definition --cli-input-json file://./tasks/definition.json --family $TASKS_FAMILY --region $REGION)
revision=$(echo "$json" | grep -o '"revision": [0-9]*' | grep -Eo '[0-9]+')
json=$(aws ecs update-service --cluster $ECS_CLUSTER_NAME --service $ECS_SERVICE_NAME --task-definition $TASKS_FAMILY:$revision --region $REGION)

# Cleanup temp env file
rm -rf .env.build

