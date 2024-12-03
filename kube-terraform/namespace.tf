resource "kubernetes_namespace" "eks_ns" {
  count = length(var.namespaces_names)
  metadata {
    name = var.namespaces_names[count.index]
  }
}