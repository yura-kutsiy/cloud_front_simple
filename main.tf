provider "aws" {
  region = var.region
}

locals {
  mime_types = jsondecode(file("${path.module}/mime.json"))
}

locals {
  s3_origin_id = "s_3_b-Origin"
}

resource "aws_s3_bucket" "website" {
  bucket = "terraform-s3-website"
  acl    = "private"
  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name        = "web-site bucket"
    Environment = "dev"
  }
}


resource "aws_s3_bucket_public_access_block" "pab" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = false
}

resource "aws_s3_bucket_object" "upload_file" {
  for_each     = fileset("websitefolder/", "*")
  bucket       = aws_s3_bucket.website.id
  acl          = "public-read"
  key          = each.value
  source       = "websitefolder/${each.value}"
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)
  etag         = filemd5("websitefolder/${each.value}")
}

resource "aws_cloudfront_origin_access_identity" "acfoai" {
  comment = "access to s3_bucket web-site"
}

resource "aws_cloudfront_distribution" "s3_image_site" {
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.acfoai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "terraform_version"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "UA"]
    }
  }

  tags = {
    Environment = "dev"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
