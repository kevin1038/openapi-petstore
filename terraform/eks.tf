module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.2"

  cluster_name    = local.cluster_name
  cluster_version = "1.23"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)

  fargate_profiles = {
    openapi_petstore = {
      name      = "openapi-petstore"
      selectors = [
        {
          namespace = "openapi-petstore"
        },
        {
          namespace = "default"
        },
        {
          namespace = "kube-system"
        }
      ]
      subnet_ids = module.vpc.private_subnets
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

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
