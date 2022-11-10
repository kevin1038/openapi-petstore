variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "opensearch_allow_ip" {
  description = "OpenSearch IP-based access policy"
  type        = string
  default     = "0.0.0.0/0"
}

variable "aws_grafana_sso_user_email" {
  description = "Admin user for Grafana"
  type        = string
}
