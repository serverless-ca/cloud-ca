variable "hosted_zone_domain" {
  description = "Hosted Zone Domain"
  default     = "certs.cloud-ca.com" # Change to subdomain hosted zone for CRL publication within same AWS account
}

variable "s3_aws_principals" {
  description = "AWS principals allowed to get certificate info from external CA S3 bucket"
  default     = []
}