terraform {
  required_version = ">= 1.6.0"

  required_providers {
    okta = {
      source  = "okta/okta"
      version = "~> 7.0"
    }
  }
}

# Authentication comes from environment variables so no secret ever lands in this repo:
#   OKTA_ORG_NAME            your org prefix, for example integrator-1234567
#   OKTA_BASE_URL            okta.com
#   OKTA_API_CLIENT_ID       client ID of the "Terraform" API Services app
#   OKTA_API_PRIVATE_KEY_ID  key ID (kid) shown next to the public key in that app
#   OKTA_API_PRIVATE_KEY     path to the private key PEM file, kept outside this repo
#   OKTA_API_SCOPES          okta.users.manage,okta.groups.manage,okta.apps.manage
provider "okta" {}
