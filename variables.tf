variable "hosted_zone_domain" {
  description = "Hosted Zone Domain"
  default     = "certs.cloud-ca.com" # Change to subdomain hosted zone for CRL publication within same AWS account
}

variable "cloud_app_user_arn" {
  description = "ARN of cloud app IAM user allowed to get certificate info from external CA S3 bucket"
  default     = ""
}