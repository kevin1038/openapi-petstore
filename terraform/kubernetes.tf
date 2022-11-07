resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "openapi-petstore"
  }
}

resource "kubernetes_namespace" "aws_observability" {
  metadata {
    name = "aws-observability"
    labels = {
      aws-observability = "enabled"
    }
  }

  depends_on = [module.eks.fargate_profiles]
}

resource "kubernetes_config_map" "aws_logging" {
  metadata {
    name      = "aws-logging"
    namespace = kubernetes_namespace.aws_observability.id
  }

  data = {
    "output.conf" = <<OUTPUT
[OUTPUT]
  Name  es
  Match *
  Host  ${aws_opensearch_domain.opensearch.endpoint}
  Port  443
  AWS_Auth On
  AWS_Region ${data.aws_region.current.name}
  tls   On
OUTPUT
  }
}
