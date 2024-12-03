variable "externaldns_policy_name" {
  description = "externaldns_policy_name"
  type        = string
  default     = "AllowExternalDNSUpdates"
}

# variable "role_namespace" {
#   description = "role_namespace"
#   type        = string
#   default     = "default"
# }

variable "externaldns_role_name" {
  description = "externaldns_role_name"
  type        = string
  default     = "ce7-ty-external-dns"
}

variable "cluster_name" {
  description = "eks_cluster_name"
  type        = string
  default     = "ce7-grp-1-eks"
}

variable "namespaces_names" {
  description = "namespaces to be created"
  type        = list(string)
  default     = ["dev", "prod", "monitoring"]
}

variable "def_tags" {
  description = "default tags"
  type = object({
    creator     = string,
    environment = string
  })
  default = {
    "creator"     = "ce7-ty",
    "environment" = "dev"
  }
}

variable "mlops_info" {
  description = "mlops configurations"
  type = object({
    service_name = string,
    namespaces   = list(string),
    service_port = number,
    url_name     = string,
  })

  default = {
    "service_name" = "fast-api-service",
    "namespaces"   = ["dev", "prod"],
    "service_port" = 80,
    "url_name"     = "mlops"
  }
}

variable "helm_info" {
  description = "helm configurations"
  type        = list(list(string))

  default = [
    #Template for helm list object ["release", "repo_url", "chart", "create namespace (boolean)", "namespace", "value_path"]
    ["ce7-grp-1-nginx", "https://kubernetes.github.io/ingress-nginx", "ingress-nginx", "false", "default", ""],
    # ["ce7-grp-1-prome", "https://prometheus-community.github.io/helm-charts", "kube-prometheus-stack", "true", "monitoring", "/helm_values/prome-value.yaml"],
    ["ce7-grp-1-loki", "https://grafana.github.io/helm-charts", "loki-stack", "true", "loki", ""],
  ]
}

variable "externaldns_info" {
  type = object({
    release_name = string,
    repo         = string,
    chart        = string,
    create_ns    = bool,
    namespace    = string,
    value_path   = string
  })

  default = {
    "release_name" = "external-dns",
    "repo"         = "https://kubernetes-sigs.github.io/external-dns/",
    "chart"        = "external-dns",
    "create_ns"    = true,
    "namespace"    = "default",
    "value_path"   = "/helm_values/templates/externaldns-rbac.yaml"
  }
}

variable "prome_info" {
  type = object({
    release_name = string,
    repo         = string,
    chart        = string,
    create_ns    = bool,
    namespace    = string,
    value_path   = string
  })

  default = {
    "release_name" = "ce7-grp-1-prome",
    "repo"         = "https://prometheus-community.github.io/helm-charts",
    "chart"        = "kube-prometheus-stack",
    "create_ns"    = true,
    "namespace"    = "monitoring",
    "value_path"   = "/helm_values/prome-value.yaml"
  }
}

# variable "grafana_cloudwatch_role_name" {
#   description = "grafana cloudwatch configurations"
#   type        = string
#   default     = "ce7-grp-1-grafana-cloudwatch"
# }

# variable "eks_clusr_conf" {
#   description = "eks cluster configurations"
#   type = object({
#     cluster_name       = string,
#     node_group_name    = string,
#     node_scale_desired = number,
#     node_scale_max     = number,
#     node_scale_min     = number,
#     max_unavail        = number
#   })

#   default = {
#     "cluster_name"       = "ce7-ty-eks",
#     "node_group_name"    = "ce7-ty-eks-nodes",
#     "node_scale_desired" = 2,
#     "node_scale_max"     = 3,
#     "node_scale_min"     = 1,
#     "max_unavail"        = 1
#   }
# }

# variable "def_tags" {
#   description = "default tags"
#   type = object({
#     creator     = string,
#     environment = string
#   })
#   default = {
#     "creator"     = "ce7-ty",
#     "environment" = "dev"
#   }
# }

# # These are variables used in the iam.tf file.
# # The name of the variables are the block names assigned. 
# variable "iam_conf" {
#   description = "iam configurations requirements"
#   type = object({
#     eks_role               = string,
#     ce7-ty-nodes           = string,
#     eks_cluster_autoscaler = string
#   })

#   default = {
#     "eks_role"               = "ce7-ty-eks-role",
#     "ce7-ty-nodes"           = "ce7-ty-eks-node-group-nodes",
#     "eks_cluster_autoscaler" = "ce7-ty-eks-cluster-autoscaler"
#   }
# }