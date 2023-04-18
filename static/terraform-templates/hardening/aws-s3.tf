## Políticas atendidas
# [PSEC] - AWS S3 - [P] Require enable server side encryption
# [PSEC] - AWS S3 - [P] Require enable TLS 1.2 
# [PSEC] - AWS S3 - [P] Require block public access
# [PSEC] - AWS S3 - [P] Require enable logging
## Cria o bucket
resource "aws_s3_bucket" "template_bucket" {
  bucket        = "095240943-templatebucket"
  force_destroy = true
  tags = {
    Name         = "095240943-templatebucket"
    Created_From = "Terraform PSEC Template"
    Template_Doc = "https://bit.ly/wnst-psec-awss3tf"
  }

}
resource "aws_s3_bucket_acl" "template_bucket" {
  bucket = aws_s3_bucket.template_bucket.id
  acl    = "private"
}
# Implementa os requisitos de segurança
# [PSEC] - AWS S3 - [P] Require enable server side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "template_bucket" {
  bucket = aws_s3_bucket.template_bucket.id

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
# [PSEC] - AWS S3 - [P] Require enable TLS 1.2 
resource "aws_s3_bucket_policy" "template_bucket" {
  bucket = aws_s3_bucket.template_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "BUCKET-POLICY"
    Statement = [
      {
        Sid       = "EnforceTls"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.template_bucket.arn}/*",
          "${aws_s3_bucket.template_bucket.arn}",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid       = "EnforceTLSVersion"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.template_bucket.arn}/*",
          "${aws_s3_bucket.template_bucket.arn}",
        ]
        Condition = {
          NumericLessThan = {
            "s3:TlsVersion" : 1.2
          }
        }
      }
    ]
  })
}

# [PSEC] - AWS S3 - [P] Require block public access
resource "aws_s3_bucket_public_access_block" "template_bucket" {
  bucket = aws_s3_bucket.template_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
### Logging settings
## [PSEC] - AWS S3 - [P] Require enable logging
resource "aws_s3_bucket_logging" "template_bucket" {
  bucket = aws_s3_bucket.template_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}
#############