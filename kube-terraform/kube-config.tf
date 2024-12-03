# resource "kubernetes_secret" "sa_externaldns" {
#   metadata {
#     annotations = {
#       "kubernetes.io/service-account.name" = kubernetes_service_account.sa_externaldns.0.name
#     }
#     namespace = "default"
#     name      = "${kubernetes_service_account.sa_externaldns.metadata.0.name}-token"
#   }
#   type                           = "kubernetes.io/service-account-token"
#   wait_for_service_account_token = true
# }

# resource "kubernetes_service_account" "sa_externaldns" {
#   metadata {
#     name      = "sa-externaldns"
#     namespace = "default"
#   }
# }

# data "kubectl_path_documents" "manifests" {
#     count = length(var.mlops_info.namespaces) 
#     pattern = "${path.cwd}/helm_values/templates/custom-ingress.yaml"
#     vars = {
#         service-name = var.mlops_info["service_name"]
#         service-port = tostring(var.mlops_info["service_port"])
#         namespace   = var.mlops_info["namespaces"][count.index]
#         ingress-rule-name = join("-", var.mlops_info["service_name"], var.mlops_info["namespaces"][count.index])
#         service-url = join("-", var.mlops_info["url-name"], var.mlops_info["namespaces"][count.index])
#                 }  
# }

resource "kubectl_manifest" "custom_rules" {
  # manifest = yamldecode(file(tostring(${path.cwd}/helm_values/templates/custom-ingress.yaml)))
  # yaml_body = element(data.kubectl_path_documents.manifests.documents)
  count = length(var.mlops_info["namespaces"])
  yaml_body = tostring(templatefile("${path.cwd}/helm_values/templates/custom-ingress.yaml", {
    service-name      = var.mlops_info["service_name"]
    service-port      = tostring(var.mlops_info["service_port"])
    namespace         = var.mlops_info["namespaces"][count.index]
    ingress-rule-name = join("-", [var.mlops_info["service_name"], var.mlops_info["namespaces"][count.index]])
    service-url       = join("-", [var.mlops_info["url_name"], var.mlops_info["namespaces"][count.index]])
    }
    )
  )
}

# resource "kubectl_manifest" "pv" {
#   yaml_body = tostring(file("${path.cwd}/kube_manifest/kube-prometheus-stack-pv.yaml"))
# }


# resource "kubectl_manifest" "pvc" {
#   yaml_body = tostring(file("${path.cwd}/kube_manifest/kube-prometheus-stack-pvc.yaml"))
# }