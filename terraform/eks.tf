module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.2"

  cluster_name    = local.cluster_name
  cluster_version = "1.23"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  fargate_profiles = {
    openapi_petstore = {
      name      = "openapi-petstore"
      selectors = [
        {
          namespace = "openapi-petstore"
        }
      ]
    },
    kube_system = {
      name      = "kube-system"
      selectors = [
        {
          namespace = "kube-system"
        }
      ]
    }
  }
}

locals {
  cluster_name = "openapi-petstore-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}
