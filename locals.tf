locals {
  issuing_ca_info = {
    country              = "GB"
    locality             = "London"
    lifetime             = 3650
    organization         = "Cloud CA"
    organizationalUnit   = "Security Operations"
    commonName           = "Cloud Issuing CA"
    pathLengthConstraint = 0
  }

  root_ca_info = {
    country              = "GB"
    locality             = "London"
    lifetime             = 7300
    organization         = "Cloud CA"
    organizationalUnit   = "Security Operations"
    commonName           = "Cloud Root CA"
    pathLengthConstraint = 1
  }

  csr_files = [
    "cloud-architect.csr",
    "cloud-engineer.csr",
    "server-cert-request.csr",
    "server-cloud-ca-com.csr"
  ]
}
