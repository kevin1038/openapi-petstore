resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "openapi-petstore"
  }
}
