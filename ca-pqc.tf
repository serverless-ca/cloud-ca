# On a deployment from scratch, apply the ECDSA CA first, see README for details

module "certificate_authority_pqc" {
  source  = "serverless-ca/ca/aws"
  version = "4.3.0"

  project                    = "pqc"
  external_s3_bucket_name    = module.certificate_authority.external_s3_bucket_name
  existing_slack_secret_name = module.certificate_authority.slack_secret_name
  hosted_zone_domain         = var.hosted_zone_domain
  cert_info_files            = ["tls", "revoked", "revoked-root-ca"]
  csr_files                  = tolist(fileset("${path.module}/certs/dev/csrs", "*.csr"))
  issuing_ca_info            = local.pqc_issuing_ca_info
  issuing_ca_key_spec        = "ML_DSA_44"
  root_ca_info               = local.pqc_root_ca_info
  root_ca_key_spec           = "ML_DSA_65"
  public_crl                 = true
  slack_channels             = ["devsecops-dev"]
}
