module "managed_grafana" {
  source  = "terraform-aws-modules/managed-service-grafana/aws"
  version = "~>1.5.0"

  name                      = "openapi-petstore"
  associate_license         = false
  account_access_type       = "CURRENT_ACCOUNT"
  authentication_providers  = ["AWS_SSO"]
  permission_type           = "SERVICE_MANAGED"
  data_sources              = ["CLOUDWATCH", "PROMETHEUS", "XRAY"]
  notification_destinations = ["SNS"]

  # WARNING: https://github.com/hashicorp/terraform-provider-aws/issues/24166
  role_associations = {
    "ADMIN" = {
      "user_ids" = [aws_identitystore_user.admin.user_id]
    }
  }
}

resource "aws_identitystore_user" "admin" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.example.identity_store_ids)[0]

  display_name = "Admin"
  user_name    = "admin"

  name {
    given_name  = "Admin"
    family_name = "Admin"
  }

  emails {
    value = var.aws_grafana_sso_user_email
  }
}

data "aws_ssoadmin_instances" "example" {}
