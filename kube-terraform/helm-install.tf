# resource "helm_release" "nginx" {
#   upgrade_install = true

#   name       = var.helm_info["nginx_release"]
#   repository = "https://kubernetes.github.io/ingress-nginx"
#   chart      = "ingress-nginx"
#   namespace = "default"
# }

# resource "helm_release" "kube-prometheus-stack" {
#   upgrade_install = true
#   force_update    = true

#   name = var.helm_info["prome_release"]
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "kube-prometheus-stack"
#   namespace = "monitoring"

#   values = [tostring(file("${path.cwd}/helm_values/prome-value.yaml"))]

# }

# resource "helm_release" "loki-stack" {
#   upgrade_install = true
#   force_update    = true

#   name = var.helm_info["loki_release"]
#   repository = "https://grafana.github.io/helm-charts"
#   chart      = "loki-stack"
#   # namespace  = var.namespaces_names[count.index]
#   namespace = "monitoring"

# }

# locals {
#   externaldns-value = templatefile("${path.cwd}/helm_values/templates/externaldns-rbac.yaml", {
#     aws_acc_id       = data.aws_caller_identity.ACC_ID.account_id
#     externaldns_role = aws_iam_role.helm-external-dns.name
#   })
# }

# data "template_file" "prome-value" {
#   template = "${file("${path.cwd}")}"
# }

resource "helm_release" "externaldns" {
  name             = var.externaldns_info["release_name"]
  repository       = var.externaldns_info["repo"]
  chart            = var.externaldns_info["chart"]
  create_namespace = tobool(var.externaldns_info["create_ns"])
  upgrade_install  = true
  force_update     = true
  namespace        = var.externaldns_info["namespace"]

  values = [
    tostring(templatefile("${path.cwd}${var.externaldns_info["value_path"]}", {
      aws_acc_id       = data.aws_caller_identity.current.account_id
      externaldns_role = aws_iam_role.helm-external-dns.name
      })
    )
  ]
}

resource "helm_release" "prome" {
  name             = var.prome_info["release_name"]
  repository       = var.prome_info["repo"]
  chart            = var.prome_info["chart"]
  create_namespace = tobool(var.prome_info["create_ns"])
  upgrade_install  = true
  force_update     = true
  namespace        = var.prome_info["namespace"]

  values = [tostring(file("${path.cwd}${var.prome_info["value_path"]}"))]

}

resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"
}


resource "helm_release" "helm-install" {
  count            = length(var.helm_info)
  upgrade_install  = true
  force_update     = true
  create_namespace = tobool(var.helm_info[count.index][3])

  name       = var.helm_info[count.index][0]
  repository = var.helm_info[count.index][1]
  chart      = var.helm_info[count.index][2]
  namespace  = var.helm_info[count.index][4]


  values = (var.helm_info[count.index][5] == "" ? [] : [template("${path.cwd}${var.helm_info[count.index][5]}")])
  # values = [tostring(file("${path.cwd}/helm_values/prome-value.yaml"))]

  depends_on = [time_sleep.wait_30_seconds]
  # depends_on = []
}