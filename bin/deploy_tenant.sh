#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

set -e

if [ -z "${PROJECT_NAME}" ]; then
    echo "PROJECT_NAME environment variable is not exported. Exiting..."
    exit 1
fi
if [ -z "${SSH_PUBLIC_KEY}" ]; then
    echo "SSH_PUBLIC_KEY environment variable is not exported. Exiting..."
    exit 1
fi

# Define usage function
usage() {
    echo "Usage: $0 --tenant-id <tenant_id> --posix-user-id <posix_user_id> --posix-group-id <posix_group_id>"
    exit 1
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
    --tenant-id)
        tenant_id="$2"
        shift
        ;;
    --posix-user-id)
        posix_user_id="$2"
        shift
        ;;
    --posix-group-id)
        posix_group_id="$2"
        shift
        ;;
    *) usage ;;
    esac
    shift
done

# Check if the mandatory arguments are provided
if [ -z "$tenant_id" ] || [ -z "$posix_user_id" ] || [ -z "$posix_group_id" ]; then
    usage
fi

cd "$(dirname "$(dirname "$0")")"

aws cloudformation deploy \
    --stack-name ${PROJECT_NAME}-tenant-${tenant_id} \
    --template-file cloudformation/tenant.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
    ProjectName=${PROJECT_NAME} \
    TenantId=${tenant_id} \
    PosixUserId=${posix_user_id} \
    PosixGroupId=${posix_group_id} \
    SshPublicKey="${SSH_PUBLIC_KEY}"
