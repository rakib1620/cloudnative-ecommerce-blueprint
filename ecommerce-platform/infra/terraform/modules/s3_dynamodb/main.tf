# Remote State & Lock Module
terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }
}

variable "project_name" {
  type    = string
  default = "ecommerce-platform"
}

variable "environment" {
  type    = string
  default = "prod"
}

# S3 Bucket for Terraform State & Backups
resource "aws_s3_bucket" "tf_state" {
  bucket = "${var.project_name}-${var.environment}-tfstate"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State Storage"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_crypto" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state_block_public" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB Table for State Locking
resource "aws_dynamodb_table" "tf_locks" {
  name         = "${var.project_name}-${var.environment}-tflocks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = var.environment
  }
}

output "s3_bucket_id" {
  value = aws_s3_bucket.tf_state.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.tf_locks.name
}
