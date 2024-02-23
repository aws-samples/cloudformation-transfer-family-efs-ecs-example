#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

if [ -z "${PROJECT_NAME}" ]; then
    echo "PROJECT_NAME environment variable is not exported. Exiting..."
    exit 1
fi

usage() {
    echo "Usage: $0 --tenant-id <tenant_id>"
    exit 1
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
    --tenant-id)
        tenant_id="$2"
        shift
        ;;
    *) usage ;;
    esac
    shift
done

# Check if the mandatory arguments are provided
if [ -z "$tenant_id" ]; then
    usage
fi

# Set the ECS cluster and service name
ECS_SERVICE="ExampleBackend-${tenant_id}"
ECS_CLUSTER=${PROJECT_NAME}

# Get list of running tasks in the ECS service
TASKS=$(aws ecs list-tasks --cluster ${ECS_CLUSTER} --service-name ${ECS_SERVICE} --desired-status RUNNING --query 'taskArns' --output text)

# Select a random task from the list
RANDOM_TASK=$(shuf -n 1 -e ${TASKS})

# Start an ECS exec session for the selected task
aws ecs execute-command --cluster ${ECS_CLUSTER} --task ${RANDOM_TASK} --interactive --command "ls /data"
