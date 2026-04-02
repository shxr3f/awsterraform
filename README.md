# Profiles Ingestion Infrastructure (Terraform)

## Overview

This Terraform setup provisions the AWS infrastructure for a small profile ingestion pipeline used in the take-home assignment.

At a high level, the infrastructure does the following:

1. Creates a **data lake S3 bucket setup** through a reusable S3 bucket module.
2. Creates a separate **Lambda artifact bucket** to store deployment packages for the Lambda function.
3. Creates a **Secrets Manager secret** to store the external API key securely.
4. Creates an **AWS Lambda function** that will ingest profile data.
5. Creates the required **IAM roles and policies** so Lambda can:
   - read input files from S3,
   - write processed data back into the lake,
   - read the API key from Secrets Manager,
   - write logs to CloudWatch.
6. Creates a separate **GitHub Actions IAM role** using OIDC so CI/CD can deploy Lambda code without storing long-lived AWS credentials.

This design separates:
- **infrastructure concerns** from application code,
- **data lake storage** from **deployment artifacts**,
- **runtime access** from **CI/CD deployment permissions**.

---

## Files in this Terraform setup

### `main.tf`
This file contains the base Terraform setup and shared platform resources:

- Terraform version and AWS provider requirements
- S3 backend configuration for storing Terraform state
- AWS provider configuration
- Creation of the **Lambda artifacts bucket**
- Security hardening for the artifact bucket:
  - versioning enabled
  - server-side encryption enabled
  - public access fully blocked

This bucket is **not** the data lake itself.  
Its purpose is only to store Lambda deployment ZIP files.

---

### `profiles.tf`
This is the main application infrastructure file for the profile ingestion pipeline.

It contains:

- `data.aws_caller_identity.current`
  - Retrieves the AWS account ID dynamically.

- `locals`
  - Defines project-level constants such as:
    - project name
    - environment
    - region
    - Lambda artifact key
    - common tags

- `module "profiles_data_lake"`
  - Calls the reusable **S3 bucket module**
  - This module is responsible for provisioning the main project bucket and related data-lake resources

- `aws_secretsmanager_secret.pdl_api_key`
  - Stores the external API key securely in AWS Secrets Manager

- `aws_iam_role.lambda_exec`
  - IAM execution role for the Lambda function

- `aws_iam_role_policy.lambda_policy`
  - Grants Lambda permission to:
    - write logs to CloudWatch
    - list/read raw input data from the lake
    - write raw API responses and medallion outputs
    - read the secret from Secrets Manager

- GitHub Actions OIDC integration
  - `data.aws_iam_openid_connect_provider.github`
  - `data.aws_iam_policy_document.github_actions_assume_role`
  - `aws_iam_role.github_actions`
  - `aws_iam_role_policy.github_actions_policy`

  This allows GitHub Actions to:
  - assume an AWS role securely using OIDC
  - upload Lambda artifacts to S3
  - update the Lambda function code

- `aws_lambda_function.profiles_ingest`
  - The main ingestion Lambda function
  - Reads deployment package from the artifact bucket
  - Gets configuration from environment variables

- `aws_lambda_permission.allow_s3_invoke`
  - Allows S3 to invoke the Lambda function

---

### `variables.tf`
This file defines the configurable input variables for the deployment.

Currently it includes:

- `aws_region`
- `lambda_artifact_bucket`

This helps keep configuration flexible and avoids hardcoding deployment-specific values directly into the resources.

---

### `outputs.tf`
The uploaded `outputs.tf` appears to belong to the **reusable S3 bucket module**, not the root Terraform stack.

It exposes outputs such as:

- `bucket_id`
- `bucket_arn`
- `bucket_name`
- `bronze_database_name`
- `silver_database_name`
- `gold_database_name`

These outputs are used by the root stack so other resources, like Lambda and IAM policies, can reference the bucket and Glue databases created by the module.

---

## How the S3 bucket module is being used

Three of the uploaded Terraform files relate to the S3 bucket module concept:

1. The root stack in `profiles.tf` **calls the module**:
   ```hcl
   module "profiles_data_lake" {
     source = "../../modules/s3_bucket"

     project_name = local.project_name
     environment  = local.environment
     account_id   = local.account_id
     region       = local.region

     tags = merge(local.common_tags, {
       Purpose = "data-lake"
     })
   }
   ```

---

## Files in this Terraform setup

### `main.tf`
This file contains the base Terraform setup and shared platform resources:

- Terraform version and AWS provider requirements
- S3 backend configuration for storing Terraform state
- AWS provider configuration
- Creation of the **Lambda artifacts bucket**
- Security hardening for the artifact bucket:
  - versioning enabled
  - server-side encryption enabled
  - public access fully blocked

This bucket is **not** the data lake itself.  
Its purpose is only to store Lambda deployment ZIP files.

---

### `profiles.tf`
This is the main application infrastructure file for the profile ingestion pipeline.

It contains:

- `data.aws_caller_identity.current`
  - Retrieves the AWS account ID dynamically.

- `locals`
  - Defines project-level constants such as:
    - project name
    - environment
    - region
    - Lambda artifact key
    - common tags

- `module "profiles_data_lake"`
  - Calls the reusable **S3 bucket module**
  - This module is responsible for provisioning the main project bucket and related data-lake resources

- `aws_secretsmanager_secret.pdl_api_key`
  - Stores the external API key securely in AWS Secrets Manager

- `aws_iam_role.lambda_exec`
  - IAM execution role for the Lambda function

- `aws_iam_role_policy.lambda_policy`
  - Grants Lambda permission to:
    - write logs to CloudWatch
    - list/read raw input data from the lake
    - write raw API responses and medallion outputs
    - read the secret from Secrets Manager

- GitHub Actions OIDC integration
  - `data.aws_iam_openid_connect_provider.github`
  - `data.aws_iam_policy_document.github_actions_assume_role`
  - `aws_iam_role.github_actions`
  - `aws_iam_role_policy.github_actions_policy`

  This allows GitHub Actions to:
  - assume an AWS role securely using OIDC
  - upload Lambda artifacts to S3
  - update the Lambda function code

- `aws_lambda_function.profiles_ingest`
  - The main ingestion Lambda function
  - Reads deployment package from the artifact bucket
  - Gets configuration from environment variables

- `aws_lambda_permission.allow_s3_invoke`
  - Allows S3 to invoke the Lambda function

---

### `variables.tf`
This file defines the configurable input variables for the deployment.

Currently it includes:

- `aws_region`
- `lambda_artifact_bucket`

This helps keep configuration flexible and avoids hardcoding deployment-specific values directly into the resources.