resource "aws_opensearch_domain" "opensearch" {
  domain_name    = "openapi-petstore-opensearch"
  engine_version = "Elasticsearch_7.10"

  cluster_config {
    instance_type = "t3.small.search"
  }

  advanced_security_options {
    enabled = true
    master_user_options {
      master_user_arn = aws_iam_role.fargate_pod_execution_role.arn
    }
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  node_to_node_encryption {
    enabled = true
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }
}

resource "aws_opensearch_domain_policy" "opensearch" {
  domain_name = aws_opensearch_domain.opensearch.domain_name

  access_policies = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "es:*",
        "Principal" : "*",
        "Effect" : "Allow",
        "Condition" : {
          "IpAddress" : { "aws:SourceIp" : "${var.opensearch_allow_ip}" }
        },
        "Resource" : "${aws_opensearch_domain.opensearch.arn}/*"
      }
    ]
  })
}
