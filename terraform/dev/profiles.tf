data "aws_caller_identity" "current" {}

locals {
  project_name = "profiles"
  environment  = "dev"

  region     = var.aws_region
  account_id = data.aws_caller_identity.current.account_id

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