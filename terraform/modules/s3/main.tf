resource "aws_s3_bucket" "app" {
  bucket = var.bucket_name

  tags = {
    Project = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id
  versioning_configuration {
    status = "Enabled"
  }
}

# QR codes don't need to live forever - clean up anything older than 90 days
resource "aws_s3_bucket_lifecycle_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    id     = "expire-old-qr-codes"
    status = "Enabled"

    filter {
      prefix = "qr_codes/"
    }

    expiration {
      days = 90
    }
  }
}