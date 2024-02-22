module "certificate_authority" {
  source = "./terraform-aws-ca"
  # source  = "serverless-ca/terraform-aws-ca"
  # version = "1.0.0"

  hosted_zone_domain = var.hosted_zone_domain
  hosted_zone_id     = data.aws_route53_zone.public.zone_id
  cert_info_files    = ["tls", "revoked", "revoked-root-ca"]
  issuing_ca_info    = local.issuing_ca_info
  root_ca_info       = local.root_ca_info
  public_crl         = true

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1 # certificates for CloudFront must be in this region
  }
}
