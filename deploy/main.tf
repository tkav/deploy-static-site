
resource "aws_s3_bucket" "website_logs" {
  bucket = "${var.website_domain_main}-logs"

  force_destroy = true
}

resource "aws_s3_bucket_acl" "website_logs" {
  bucket = aws_s3_bucket.website_logs.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "website_root" {
  bucket = "${var.website_domain_main}-root"

  force_destroy = true
}

resource "aws_s3_bucket_acl" "website_root" {
  bucket = aws_s3_bucket.website_root.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "website_root" {
  bucket = aws_s3_bucket.website_root.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }

}

resource "aws_s3_bucket_logging" "website_root" {
  bucket = aws_s3_bucket.website_root.id

  target_bucket = aws_s3_bucket.website_logs.id
  target_prefix = "${var.website_domain_main}/"
}

resource "aws_s3_bucket_policy" "update_website_root_bucket_policy" {
  bucket = aws_s3_bucket.website_root.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "PolicyForWebsiteEndpointsPublicContent",
  "Statement": [
    {
      "Sid": "PublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "${aws_s3_bucket.website_root.arn}/*",
        "${aws_s3_bucket.website_root.arn}"
      ]
    }
  ]
}
POLICY
}

resource "aws_cloudfront_origin_access_identity" "website_origin_identity" {
}

resource "aws_cloudfront_distribution" "website_cdn_root" {
  enabled     = true
  price_class = "PriceClass_All"

  origin {
    origin_id   = "origin-bucket-${aws_s3_bucket.website_root.id}"
    domain_name = aws_s3_bucket.website_root.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website_origin_identity.cloudfront_access_identity_path
    }
  }

  default_root_object = "index.html"

  logging_config {
    bucket = aws_s3_bucket.website_logs.bucket_domain_name
    prefix = "${var.website_domain_main}/"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "origin-bucket-${aws_s3_bucket.website_root.id}"
    min_ttl          = "0"
    default_ttl      = "300"
    max_ttl          = "1200"

    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_page_path    = "/404.html"
    response_code         = 404
  }

}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.website_cdn_root.domain_name
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.website_cdn_root.id
}

output "origin_identity_id" {
  value = aws_cloudfront_origin_access_identity.website_origin_identity.id
}
