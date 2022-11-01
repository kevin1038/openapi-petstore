resource "helm_release" "metrics_server" {
  chart      = "metrics-server"
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  namespace  = "kube-system"
  version    = "3.8.2"

  depends_on = [module.eks.fargate_profiles]
}
