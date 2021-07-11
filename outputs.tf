
output "s3_bucket_domain_name" {
  value = aws_s3_bucket.website.bucket_domain_name
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.s3_image_site.domain_name
}
