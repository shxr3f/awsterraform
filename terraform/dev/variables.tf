variable "aws_region" {
  type        = string
  description = "AWS region for deployment"
  default     = "ap-southeast-1"
}

variable "lambda_artifact_bucket" {
  type        = string
  description = "Bucket Used to Store Lamda Artifacts"
  default     = "lambda-artifact-bucket-345895787413-ap-southeast-1"
}