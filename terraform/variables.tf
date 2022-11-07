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
