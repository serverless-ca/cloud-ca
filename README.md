# cloud-ca
Cloud CA demonstration built using AWS CA Terraform Module

## ECDSA Certificate Authority with private CRL

## Local Development - Terraform
```
terraform init -backend-config=bucket={YOUR_TERRAFORM_STATE_BUCKET} -backend-config=key=cloud-ca -backend-config=region={YOUR_TERRAFORM_STATE_REGION}
terraform plan
terraform apply
```