locals {
  namespace                = "prometheus"
  amp_service_account_name = "amp-iamproxy-ingest-service-account"
  amp_iam_role             = "amp-iamproxy-ingest-role"
}

module "iam_assumable_role_with_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~>5.5.0"

  create_role = true

  role_name = local.amp_iam_role

  provider_url = module.eks.oidc_provider

  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.namespace}:${local.amp_service_account_name}"]

  role_policy_arns           = [aws_iam_policy.amp.arn]
  number_of_role_policy_arns = 1
}

resource "aws_iam_policy" "amp" {
  name = "AMPIngestPolicy"

  policy = jsonencode({
    Statement = [
      {
        Action = [
          "aps:RemoteWrite",
          "aps:GetSeries",
          "aps:GetLabels",
          "aps:GetMetricMetadata"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
    Version = "2012-10-17"
  })
}

module "prometheus" {
  source  = "terraform-aws-modules/managed-service-prometheus/aws"
  version = "~>2.2.0"

  workspace_alias = "openapi-petstore"
}

resource "helm_release" "prometheus" {
  chart            = "prometheus"
  name             = "prometheus-for-amp"
  repository       = "https://prometheus-community.github.io/helm-charts"
  namespace        = local.namespace
  create_namespace = true
  version          = "15.18.0"

  values = [
    yamlencode({
      nodeExporter = {
        enabled = false
      }

      alertmanager = {
        enabled = false
      }

      serviceAccounts = {
        server = {
          annotations = {
            "eks.amazonaws.com/role-arn" = module.iam_assumable_role_with_oidc.iam_role_arn
          }
          name = local.amp_service_account_name
        }
      }

      server = {
        persistentVolume = {
          enabled = false
        }
        remoteWrite = [
          {
            sigv4 = {
              region = data.aws_region.current.name
            }
            queue_config = {
              max_samples_per_send = 1000
              max_shards           = 200
              capacity             = 2500
            }
            url = "https://aps-workspaces.${data.aws_region.current.name}.amazonaws.com/workspaces/${module.prometheus.workspace_id}/api/v1/remote_write"
          }
        ]
      }
    })
  ]

  depends_on = [module.eks.fargate_profiles]
}
