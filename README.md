# Example project to integrate Amazon ECS, Amazon EFS and AWS Transfer Family

In this example project, we integrate AWS services such as Amazon Elastic Container Service (ECS), Amazon Elastic File System (EFS), and AWS Transfer Family to address the need for efficient, secure file transfers in a multi-tenant environment. By seamlessly connecting an AWS Transfer Family server to Amazon ECS tasks via Amazon EFS, we streamline file transfer operations for various tenants while ensuring isolation and resource efficiency.

## Overview

This example project demonstrates how to set up a containerized application environment using Amazon ECS for task orchestration, Amazon EFS for shared file storage, and AWS Transfer Family for secure file transfer protocols such as SFTP, FTPS, and FTP. By combining these AWS services and adopting a multi-tenant approach, users can deploy a highly available, scalable, and cost-effective solution for managing file transfers across different clients and applications.

## Architecture

The CloudFormation templates include the resources:

- Amazon ECS cluster (shared between tenants)
- Amazon ECS services (per tenant)
- Amazon Transfer Family server (shared between tenants)
- Amazon EFS volume (shared between tenants)
- Amazon EFS access points (per tenant)

## Prerequisites

1. AWS CLI:
   Install and configure the AWS Command Line Interface (CLI) on your local machine. The CLI is used to interact with AWS services and resources.

## Deployment

These deployment instructions are optimized to best work on Mac. Deployment in another OS may require additional steps.

1. Setup the required environment variables

```
export AWS_REGION=<<replace with your region (i.e. ap-southeast-2)>>
export AWS_ACCOUNT_ID=<<replace with your 12 digit AWS account ID>>
export PROJECT_NAME=example-efs-project  # or replace with a name of your choosing
export SSH_PUBLIC_KEY=<<replace with SSH public key used for SFTP access>
```

If necessary, also export your AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY values to gain programmatic access to your AWS account (it will be needed for subsequent steps).

2. Deploy the base infrastructure (i.e. VPC, subnets)

```
bin/deploy_base.sh
```

4. Deploy the shared app infrastructure (i.e. ECS cluster, Transfer Family server)

```
bin/deploy_app.sh
```

5. Deploy a tenant's infrastructure (i.e. ECS service, EFS access point)

```
bin/deploy_tenant.sh --tenant-id abc --posix-user-id 100 --posix-group-id 100
```

6. Continue to add as many tenants as you need

```
bin/deploy_tenant.sh --tenant-id xyz --posix-user-id 200 --posix-group-id 200
```

# Testing

You can manually test that the EFS file systems have successfully mounted with tenant isolation (via access points) by:

1. Create an empty test file to be used for upload.

```
touch /tmp/test_file
```

2. Start a SFTP session with Transfer Family server for tenant `abc`.

```
sftp abc@<<replace with Transfer Family server ID>>.server.transfer.<<replace with AWS region>>.amazonaws.com
```

3. Use the SFTP command to upload the test file.

```
put /tmp/test_file /abc/
```

Your file should now be uploaded in tenant `abc`'s root directory.

4. Confirm that the file is accessible from tenant `abc`'s ECS service using ECS exec.

```
bin/list_efs_tenant_files.sh --tenant-id abc
```

In the output you should see the file that you uploaded in step 3.

## Clean Up

There is a chain of dependencies between the CloudFormation stacks.
`app.yaml` relies on exports from `base.yaml`, and `tenant.yaml` relies on exports from `app.yaml`.

To account for this and avoid dependencies when cleaning up, delete stacks in order of `tenant.yaml` -> `app.yaml` -> `app.yaml`.
