module "certificate_authority" {
  source  = "serverless-ca/ca/aws"
  version = "1.7.1"

  hosted_zone_domain = var.hosted_zone_domain
  hosted_zone_id     = data.aws_route53_zone.public.zone_id
  cert_info_files    = ["tls", "revoked", "revoked-root-ca"]
  csr_files          = local.csr_files
  issuing_ca_info    = local.issuing_ca_info
  root_ca_info       = local.root_ca_info
  public_crl         = true
  s3_aws_principals  = local.s3_aws_principals

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1 # certificates for CloudFront must be in this region
  }
}
