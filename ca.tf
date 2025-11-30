module "certificate_authority" {
  source  = "serverless-ca/ca/aws"
  version = "2.2.3"

  hosted_zone_domain  = var.hosted_zone_domain
  hosted_zone_id      = data.aws_route53_zone.public.zone_id
  cert_info_files     = ["tls", "revoked", "revoked-root-ca"]
  csr_files           = tolist(fileset("${path.module}/certs/dev/csrs", "*.csr"))
  issuing_ca_info     = local.issuing_ca_info
  issuing_ca_key_spec = "ECC_NIST_P256"
  root_ca_info        = local.root_ca_info
  root_ca_key_spec    = "ECC_NIST_P256"
  public_crl          = true
  s3_aws_principals   = local.s3_aws_principals

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1 # certificates for CloudFront must be in this region
  }
}
