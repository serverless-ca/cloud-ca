# cloud-ca
Cloud CA demonstration built using AWS CA Terraform Module

## CA Overview
* ECDSA Issuing and Root CA
* Public certs and CRL
* Environment: `dev`

## CA Certificates and CRLs

### CRL Distribution Point (CDP)

|                                       CDP - Root CA                                        |                                         CDP - Issuing CA                                         |
:------------:|:------------:|
|                    http://certs.cloud-ca.com/serverless-root-ca-dev.crl                     |                      http://certs.cloud-ca.com/serverless-issuing-ca-dev.crl                      |

### Authority Information Access (AIA)

|                                       AIA - Root CA                                        |                                       AIA - Issuing CA                                        |
|:------------:|:------------:|
|                    http://certs.cloud-ca.com/serverless-root-ca-dev.crt                     |                    http://certs.cloud-ca.com/serverless-issuing-ca-dev.crt                     |

### CA Bundle (for TrustStore)

|                                          CA Bundle                                           |
|:--------------------------------------------------------------------------------------------:|
|                      http://certs.cloud-ca.com/serverless-ca-bundle-dev.pem                       |


## Create client certificate
* log in to the CA AWS account with your terminal using AWS CLI, e.g. `aws sso login` or set AWS environment variables
* from the root of this repository:
```
python -m venv .venv
source .venv/bin/activate (Linux / MacOS)
.venv/scripts/activate (Windows PowerShell)
pip install -r tests/requirements-dev.txt
python tests/client-cert.py
```
* you will now have a client key and certificate on your laptop
* bundled Root CA and Issuing CA certs are also provided



## Local Development - Terraform
```
terraform init -backend-config=bucket={YOUR_TERRAFORM_STATE_BUCKET} -backend-config=key=cloud-ca -backend-config=region={YOUR_TERRAFORM_STATE_REGION}
terraform plan
terraform apply
```
