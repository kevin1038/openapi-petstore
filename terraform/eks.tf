module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~>18.30.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.23"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)

  fargate_profiles = {
    defaultfp = {
      selectors = [
        {
          namespace = "openapi-petstore"
        },
        {
          namespace = "kube-system"
        },
        {
          namespace = "prometheus"
        }
      ]
      name            = "defaultfp"
      subnet_ids      = module.vpc.private_subnets
      create_iam_role = false
      iam_role_arn    = aws_iam_role.fargate_pod_execution_role.arn
    }
  }
}

resource "aws_iam_role" "fargate_pod_execution_role" {
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:fargateprofile/${local.cluster_name}/*"
          }
        },
        "Principal" : {
          "Service" : "eks-fargate-pods.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  name = "AmazonEKSFargatePodExecutionRole"
}

resource "aws_iam_policy" "fargate_logging_policy" {
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "es:*",
        "Resource" : "*"
      }
    ]
  })
  name = "eks-fargate-logging-policy"
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = local.fargate_pod_execution_role_policy_attachments

  policy_arn = each.value
  role       = aws_iam_role.fargate_pod_execution_role.name
}

locals {
  fargate_pod_execution_role_policy_attachments = {
    pod_execution = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy",
    cni           = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy",
    logging       = aws_iam_policy.fargate_logging_policy.arn
  }
  cluster_name = "openapi-petstore"
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
