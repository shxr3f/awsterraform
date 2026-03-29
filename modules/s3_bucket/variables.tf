variable "project_name" {
  type        = string
  description = "Project name used in bucket and Glue database naming"
}

variable "environment" {
  type        = string
  description = "Environment name such as dev, qa, prod"
}

variable "account_id" {
  type        = string
  description = "AWS account ID"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "versioning_enabled" {
  type        = bool
  description = "Enable bucket versioning"
  default     = true
}

variable "sse_algorithm" {
  type        = string
  description = "Server-side encryption algorithm"
  default     = "AES256"
}

variable "bucket_key_enabled" {
  type        = bool
  description = "Enable S3 bucket key"
  default     = true
}

variable "block_public_acls" {
  type    = bool
  default = true
}

variable "block_public_policy" {
  type    = bool
  default = true
}

variable "ignore_public_acls" {
  type    = bool
  default = true
}

variable "restrict_public_buckets" {
  type    = bool
  default = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the bucket"
  default     = {}
}