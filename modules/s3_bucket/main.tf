resource "aws_s3_bucket" "this" {
  bucket = "${var.project_name}-${var.environment}-${var.account_id}-${var.region}"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-${var.account_id}-${var.region}"
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
    }

    bucket_key_enabled = var.bucket_key_enabled
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_object" "raw_prefix" {
  bucket  = aws_s3_bucket.this.id
  key     = "raw/"
  content = ""
}

resource "aws_s3_object" "bronze_prefix" {
  bucket  = aws_s3_bucket.this.id
  key     = "bronze/"
  content = ""
}

resource "aws_s3_object" "silver_prefix" {
  bucket  = aws_s3_bucket.this.id
  key     = "silver/"
  content = ""
}

resource "aws_s3_object" "gold_prefix" {
  bucket  = aws_s3_bucket.this.id
  key     = "gold/"
  content = ""
}

resource "aws_s3_object" "athena_results_prefix" {
  bucket  = aws_s3_bucket.this.id
  key     = "athena-results/"
  content = ""
}

resource "aws_glue_catalog_database" "bronze" {
  name = "${var.project_name}_bronze"
}

resource "aws_glue_catalog_database" "silver" {
  name = "${var.project_name}_silver"
}

resource "aws_glue_catalog_database" "gold" {
  name = "${var.project_name}_gold"
}

resource "aws_athena_workgroup" "this" {
  name = "${var.project_name}-${var.environment}"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.this.bucket}/athena-results/"
    }
  }
}
