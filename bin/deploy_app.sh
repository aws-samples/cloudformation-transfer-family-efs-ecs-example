#!/bin/bash

if [ -z "${PROJECT_NAME}" ]; then
    echo "PROJECT_NAME environment variable is not exported. Exiting..."
    exit 1
fi

cd "$(dirname "$(dirname "$0")")"

aws cloudformation deploy \
    --stack-name ${PROJECT_NAME}-app \
    --template-file cloudformation/app.yaml \
    --capabilities CAPABILITY_NAMED_IAM
