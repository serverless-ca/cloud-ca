variable "hosted_zone_domain" {
  description = "Hosted Zone Domain"
  default     = "certs.cloud-ca.com" # Change to subdomain hosted zone for CRL publication within same AWS account
}