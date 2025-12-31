# Cloudflare R2 Backend Configuration
#
# NOTE: This is commented out for initial testing.
# Uncomment after creating R2 bucket and configuring credentials.
#
# terraform {
#   backend "s3" {
#     bucket = "yamisskey-terraform-state"
#     key    = "production/terraform.tfstate"
#     region = "auto"
#
#     endpoints = {
#       s3 = "https://<YOUR_ACCOUNT_ID>.r2.cloudflarestorage.com"
#     }
#
#     skip_credentials_validation = true
#     skip_region_validation      = true
#     skip_requesting_account_id  = true
#     skip_metadata_api_check     = true
#   }
# }

# For initial testing, state will be stored locally.
# Run 'terraform init' to initialize.
