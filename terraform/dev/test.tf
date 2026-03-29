data "aws_caller_identity" "current" {}

module "test_bucket" {
  source = "../../modules/s3_bucket"

  name       = "test"
  account_id = data.aws_caller_identity.current.account_id
  region     = "ap-southeast-1"

  tags = {
    Environment = "dev"
  }
}