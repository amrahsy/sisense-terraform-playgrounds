resource "aws_s3_bucket" "sisense_s3_bucket" {
  bucket_prefix = lower("${local.environment_name}")

  tags = {
    terraform_environment_name = "${local.environment_name}"
  }
}

# S3 Bucket Lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "sisense_s3_bucket_retention" {
  bucket = aws_s3_bucket.sisense_s3_bucket.id
  rule {
    expiration {
      days = 14
    }
    id = "deleteold"
    filter {
      prefix = "*"
    }
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 14
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

# S3 buckets access to all EKS Managed Node groups
resource "aws_iam_role_policy_attachment" "s3_access_managed_node_groups" {
  for_each = module.eks.eks_managed_node_groups

  policy_arn = var.s3_full_access_arn
  role       = each.value.iam_role_name
}