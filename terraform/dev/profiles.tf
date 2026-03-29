data "aws_caller_identity" "current" {}

locals {
  project_name = "profiles"
  environment  = "dev"

  region     = var.aws_region
  account_id = data.aws_caller_identity.current.account_id
  lambda_artifact_key    = "profiles/v1.0.0/profiles_ingest.zip"
  
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}

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

resource "aws_iam_role" "lambda_exec" {
  name = "${local.project_name}-${local.environment}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${local.project_name}-${local.environment}-lambda-policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${local.region}:${local.account_id}:*"
      },
      {
        Sid    = "AllowReadInput"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          module.profiles_data_lake.bucket_arn
        ]
      },
      {
        Sid    = "AllowReadInputObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "${module.profiles_data_lake.bucket_arn}/raw/input/*"
        ]
      },
      {
        Sid    = "AllowWriteMedallion"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = [
          "${module.profiles_data_lake.bucket_arn}/raw/api_response/*",
          "${module.profiles_data_lake.bucket_arn}/bronze/*",
          "${module.profiles_data_lake.bucket_arn}/silver/*",
          "${module.profiles_data_lake.bucket_arn}/gold/*"
        ]
      }
    ]
  })
}
## To deply after arttifact has been pushed to bucket
# resource "aws_lambda_function" "profiles_ingest" {
#   function_name = "${local.project_name}-${local.environment}-ingest"
#   role          = aws_iam_role.lambda_exec.arn
#   runtime       = "python3.12"
#   handler       = "handler.lambda_handler"

#   s3_bucket = aws_s3_bucket.lambda_artifacts.bucket
#   s3_key    = local.lambda_artifact_key

#   timeout     = 120
#   memory_size = 256

#   environment {
#     variables = {
#       DATA_LAKE_BUCKET = module.profiles_data_lake.bucket_name
#       PROJECT_NAME     = local.project_name
#       ENVIRONMENT      = local.environment
#       BRONZE_DB        = module.profiles_data_lake.bronze_database_name
#       SILVER_DB        = module.profiles_data_lake.silver_database_name
#       GOLD_DB          = module.profiles_data_lake.gold_database_name
#     }
#   }

#   tags = local.common_tags
# }

# resource "aws_lambda_permission" "allow_s3_invoke" {
#   statement_id  = "AllowS3InvokeLambda"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.profiles_ingest.function_name
#   principal     = "s3.amazonaws.com"
#   source_arn    = module.profiles_data_lake.bucket_arn
# }

# resource "aws_s3_bucket_notification" "profiles_input_trigger" {
#   bucket = module.profiles_data_lake.bucket_id

#   lambda_function {
#     lambda_function_arn = aws_lambda_function.profiles_ingest.arn
#     events              = ["s3:ObjectCreated:*"]
#     filter_prefix       = "raw/input/"
#   }

#   depends_on = [aws_lambda_permission.allow_s3_invoke]
# }