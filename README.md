# cloud-ca
Cloud CA demonstration built using AWS CA Terraform Module

## IMPORTANT
If cloning this repository to use as a basis for your own CA, it's essential that you:
* Update to the latest version of the CA
* Delete the CSR files in the [csr directory](./certs/dev/csrs/)
* Delete references to these files in [locals.tf](./locals.tf) and [tls.json](./certs/dev/tls.json)
* Replace the contents of [revoked.json](./certs/dev/revoked.json) with an empty list `[]`
* Change the domain name listed in [variables.tf](variables.tf) to one for which there's a hosted zone in your AWS account 

## CA Overview
Two CA hierarchies are deployed to the same AWS account, hosted zone and CloudFront
distribution, from a single Terraform state, with distinct `project` names so that all
resource names, CA names and published file names differ, prefixed `serverless-` and
`pqc-` respectively:

### ECDSA CA - project `serverless` ([ca.tf](./ca.tf))
* ECDSA Issuing and Root CA
* Public certs and CRL
* Environment: `dev`
* Certs issued from CSR files
* Revoked certificate

### ML-DSA CA - project `pqc` ([ca-pqc.tf](./ca-pqc.tf))
* Fully post-quantum CA hierarchy, `ML_DSA_65` Root CA (NIST security category 3) signing
  an `ML_DSA_44` Issuing CA (category 2)
  ([FIPS 204](https://csrc.nist.gov/pubs/fips/204/final), X.509 profile per
  [RFC 9881](https://www.rfc-editor.org/rfc/rfc9881))
* Public certs and CRL, published as `pqc-` prefixed files to the ECDSA CA's external S3
  bucket via `external_s3_bucket_name`, and served by its existing CloudFront distribution
  at the same domain - no additional CloudFront distribution, TLS certificate or DNS
  record is created, so `hosted_zone_id` isn't needed for this deployment
* Environment: `dev`
* Shares the ECDSA CA's Slack OAuth token secret via `existing_slack_secret_name`, so no
  second secret is created and the token value is only uploaded once
* Shares the same [certs/dev](./certs/dev) GitOps files as the ECDSA CA, so the same
  certificates are also issued from this post-quantum hierarchy
* See the [Post Quantum Cryptography how-to guide](https://serverlessca.com/how-to-guides/pqc-ca/)

## CA Certificates and CRLs

### CRL Distribution Point (CDP)

|                                       CDP - Root CA                                        |                                         CDP - Issuing CA                                         |
:------------:|:------------:|
|                    [http://certs.cloud-ca.com/serverless-root-ca-dev.crl](https://certs.cloud-ca.com/serverless-root-ca-dev.crl)                     |                      [http://certs.cloud-ca.com/serverless-issuing-ca-dev.crl](https://certs.cloud-ca.com/serverless-issuing-ca-dev.crl)                      |

### Authority Information Access (AIA)

|                                       AIA - Root CA                                        |                                       AIA - Issuing CA                                        |
|:------------:|:------------:|
|                    [http://certs.cloud-ca.com/serverless-root-ca-dev.crt](https://certs.cloud-ca.com/serverless-root-ca-dev.crt)                     |                    [http://certs.cloud-ca.com/serverless-issuing-ca-dev.crt](https://certs.cloud-ca.com/serverless-issuing-ca-dev.crt)                     |

### CA Bundle (for TrustStore)

|                                          CA Bundle                                           |
|:--------------------------------------------------------------------------------------------:|
|                      [http://certs.cloud-ca.com/serverless-ca-bundle-dev.pem](https://certs.cloud-ca.com/serverless-ca-bundle-dev.pem)                       |

## ML-DSA CA Certificates and CRLs

### CRL Distribution Point (CDP)

|                                       CDP - Root CA                                        |                                         CDP - Issuing CA                                         |
:------------:|:------------:|
|                    [http://certs.cloud-ca.com/pqc-root-ca-dev.crl](https://certs.cloud-ca.com/pqc-root-ca-dev.crl)                     |                      [http://certs.cloud-ca.com/pqc-issuing-ca-dev.crl](https://certs.cloud-ca.com/pqc-issuing-ca-dev.crl)                      |

### Authority Information Access (AIA)

|                                       AIA - Root CA                                        |                                       AIA - Issuing CA                                        |
|:------------:|:------------:|
|                    [http://certs.cloud-ca.com/pqc-root-ca-dev.crt](https://certs.cloud-ca.com/pqc-root-ca-dev.crt)                     |                    [http://certs.cloud-ca.com/pqc-issuing-ca-dev.crt](https://certs.cloud-ca.com/pqc-issuing-ca-dev.crt)                     |

### CA Bundle (for TrustStore)

|                                          CA Bundle                                           |
|:--------------------------------------------------------------------------------------------:|
|                      [http://certs.cloud-ca.com/pqc-ca-bundle-dev.pem](https://certs.cloud-ca.com/pqc-ca-bundle-dev.pem)                       |

ML-DSA certificates and CRLs require a relying party with ML-DSA support, e.g. OpenSSL 3.5+,
Java 25+ or Python `cryptography` 48.0.0+:

```
curl -sO https://certs.cloud-ca.com/pqc-ca-bundle-dev.pem
openssl x509 -in pqc-ca-bundle-dev.pem -text -noout
```


## Create client certificate
* log in to the CA AWS account with your terminal using AWS CLI, e.g. `aws sso login` or set AWS environment variables
* from the root of this repository:
```
python -m venv .venv
source .venv/bin/activate (Linux / MacOS)
.venv/scripts/activate (Windows PowerShell)
pip install -r utils/requirements.txt
python utils/client-cert.py
```
* you will now have a client key and certificate on your laptop at `~/certs`
* bundled Root CA and Issuing CA certs are also provided
* optional arguments:
    * `--profile <your-aws-profile>` AWS profile from `~/.aws/config`
    * `--keyalgo ecdsa|ml-dsa-44|ml-dsa-65|ml-dsa-87` subject key algorithm, default `ecdsa`
    * `--project pqc` selects the ML-DSA CA, as two CA deployments share this AWS account
    * `--verbose` prints the full Lambda response

## Create post-quantum client certificate
To issue a fully post-quantum client certificate, request an ML-DSA subject key from the
ML-DSA CA:

```
python utils/client-cert.py --keyalgo ml-dsa-44 --project pqc
```

* the ML-DSA-44 key pair is generated locally, as AWS KMS `GenerateDataKeyPair` doesn't
  support ML-DSA key pair specs
* the CSR is signed with the local ML-DSA key and submitted to the `pqc-tls-cert-dev`
  Lambda function, which issues the certificate signed by the ML-DSA Issuing CA
* the private key is written in PKCS8 format, the only format ML-DSA keys support
* `--keyalgo ml-dsa-44` with no `--project` issues an ML-DSA subject key certificate from
  the ECDSA CA instead, which is a valid mixed chain

Verify the certificate with OpenSSL 3.5+, which is needed for ML-DSA signatures:

```
openssl verify -CAfile ~/certs/ca-bundle.pem ~/certs/client-cert.crt
openssl x509 -in ~/certs/client-cert.crt -text -noout
```


## Local Development - Terraform
```
terraform init -backend-config=bucket={YOUR_TERRAFORM_STATE_BUCKET} -backend-config=key=cloud-ca -backend-config=region={YOUR_TERRAFORM_STATE_REGION}
terraform plan
terraform apply
```

Both CAs are managed in this single Terraform state. The ML-DSA CA uses the ECDSA CA's
external S3 bucket and Slack OAuth token secret, so when deploying to an empty account
apply the ECDSA CA first, for the bucket name to be known when the ML-DSA CA is planned:
```
terraform apply -target=module.certificate_authority
terraform apply
```

Scripts and utilities take an optional `CA_PROJECT` environment variable (`serverless` or
`pqc`) to select a deployment, e.g.:
```
CA_PROJECT=pqc python scripts/start_ca_step_function.py
```
