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
}
