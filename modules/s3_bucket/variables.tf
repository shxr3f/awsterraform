variable "name" {
  type = string
}

variable "account_id" {
  type = string
}

variable "region" {
  type = string
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
  description = "Enable bucket key for SSE configuration"
  default     = true
}

variable "block_public_acls" {
  type        = bool
  default     = true
}

variable "block_public_policy" {
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  type        = bool
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the bucket"
  default     = {}
}