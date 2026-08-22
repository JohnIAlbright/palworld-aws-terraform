resource "aws_s3_bucket" "palworld_backups" {
  bucket = var.backup_bucket_name
}
resource "aws_s3_bucket_versioning" "palworld_backups" {
  bucket = aws_s3_bucket.palworld_backups.id

  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "palworld_backups" {
  bucket = aws_s3_bucket.palworld_backups.id

  rule {
    id     = "ExpirePalworldBackups30Days"
    status = "Enabled"

    filter {
      prefix = "backups/"
    }

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}
resource "aws_s3_bucket_public_access_block" "palworld_backups" {
  bucket = aws_s3_bucket.palworld_backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}