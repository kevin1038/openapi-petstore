# The following Lambda resource fixes a CoreDNS issue on Fargate EKS clusters

data "archive_file" "bootstrap_archive" {
  type        = "zip"
  source_dir  = "files/lambda/python"
  output_path = "files/lambda/python.zip"
}

resource "aws_security_group" "bootstrap" {
  name_prefix = local.cluster_name
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "bootstrap" {
  name_prefix        = local.cluster_name
  assume_role_policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
JSON
}

resource "aws_iam_role_policy_attachment" "bootstrap" {
  role       = aws_iam_role.bootstrap.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "bootstrap" {
  function_name    = "${local.cluster_name}-bootstrap"
  runtime          = "python3.7"
  handler          = "main.handler"
  role             = aws_iam_role.bootstrap.arn
  filename         = data.archive_file.bootstrap_archive.output_path
  source_code_hash = data.archive_file.bootstrap_archive.output_base64sha256
  timeout          = 120

  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.bootstrap.id]
  }
}

data "aws_lambda_invocation" "bootstrap" {
  function_name = aws_lambda_function.bootstrap.function_name
  input         = <<JSON
{
  "endpoint": "${module.eks.cluster_endpoint}",
  "token": "${data.aws_eks_cluster_auth.cluster.token}"
}
JSON

  depends_on = [aws_lambda_function.bootstrap, module.eks.fargate_profiles]
}
