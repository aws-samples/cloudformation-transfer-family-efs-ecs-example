#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

if [ -z "${PROJECT_NAME}" ]; then
    echo "PROJECT_NAME environment variable is not exported. Exiting..."
    exit 1
fi

cd "$(dirname "$(dirname "$0")")"

aws cloudformation deploy \
    --stack-name ${PROJECT_NAME}-base \
    --template-file cloudformation/base.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
    ProjectName=${PROJECT_NAME}
