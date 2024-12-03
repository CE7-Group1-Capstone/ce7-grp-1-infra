resource "helm_release" "externaldns" {
  name             = var.externaldns_info["release_name"]
  repository       = var.externaldns_info["repo"]
  chart            = var.externaldns_info["chart"]
  create_namespace = tobool(var.externaldns_info["create_ns"])
  upgrade_install  = tobool(var.externaldns_info["upgrade_install"])
  force_update     = tobool(var.externaldns_info["force_update"])
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
  upgrade_install  = tobool(var.prome_info["upgrade_install"])
  force_update     = tobool(var.prome_info["force_update"])
  namespace        = var.prome_info["namespace"]

  values = [tostring(file("${path.cwd}${var.prome_info["value_path"]}"))]

  # set {
  #   name  = "server.persistentVolume.enabled"
  #   value = true
  #   # type  = "string"
  # }

  # set {
  #   name  = "server.persistentVolume.existingClaim"
  #   value = "kube-prometheus-stack-pvc"
  #   # type  = "string"
  # }

  # set {
  #   name  = "grafana.persistentVolume.existingClaim"
  #   value = "kube-prometheus-stack-pvc"
  #   # type  = "string"
  # }

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


  values = (var.helm_info[count.index][5] == "" ? [] : [file("${path.cwd}${var.helm_info[count.index][5]}")])
  # values = [tostring(file("${path.cwd}/helm_values/prome-value.yaml"))]

  depends_on = [time_sleep.wait_30_seconds]
  # depends_on = []
}