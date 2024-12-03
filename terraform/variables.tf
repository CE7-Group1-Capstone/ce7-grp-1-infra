# variable "backend_conf" {
#   description = "backend configurations"
#   type = object({
#     bucket = string,
#     key    = string,
#     region = string
#   })

#   default = {
#     "bucket" = "sctp-ce7-tfstate",
#     "key"    = "ce7-TanYuan-kube.tfstate",
#     "region" = "us-east-1"
#   }
# }

# variable "sshkey_name" {
#   description = "Name of EC2 Key Pair"
#   type        = string
#   default     = "ce7-TY-USeast1" # Change accordingly
# }

variable "s3_vpce" {
  description = "name of vpce for S3"
  type        = string
  default     = "ce7-grp-1-ty-vpce-s3"
}

variable "sg_name" {
  description = "Name of Terraform EC2 security group"
  type        = string
  default     = "ce7-grp-1-ty-sg"
}

# Referenced from https://terrateam.io/blog/terraform-types/
variable "vpc_config" {
  description = "vpc config"
  type = object({
    vpc_name    = string,
    azs         = list(string),
    pri_subnets = list(string),
    pub_subnets = list(string)
  })

  default = {
    "vpc_name"    = "ce7-grp-1-vpc"
    "azs"         = ["us-east-1a", "us-east-1b"],
    "pri_subnets" = ["10.0.1.0/24", "10.0.2.0/24"],
    "pub_subnets" = ["10.0.101.0/24", "10.0.102.0/24"]
  }
}

variable "eks_clusr_conf" {
  description = "eks cluster configurations"
  type = object({
    cluster_name       = string,
    node_group_name    = string,
    node_scale_desired = number,
    node_scale_max     = number,
    node_scale_min     = number,
    max_unavail        = number,
    node_name          = string
  })

  default = {
    "cluster_name"       = "ce7-grp-1-eks",
    "node_group_name"    = "ce7-grp-1-eks-nodes",
    "node_scale_desired" = 2,
    "node_scale_max"     = 3,
    "node_scale_min"     = 1,
    "max_unavail"        = 1,
    "node_name"          = "ce7-grp-1-ty"
  }
}

variable "def_tags" {
  description = "default tags"
  type = object({
    Name        = string,
    creator     = string,
    environment = string
  })
  default = {
    "Name"        = "ce7-grp-1-ty"
    "creator"     = "ce7-grp-1-ty",
    "environment" = "dev"
  }
}

# These are variables used in the iam.tf file.
# The name of the variables are the block names assigned. 
variable "iam_conf" {
  description = "iam configurations requirements"
  type = object({
    eks_role               = string,
    ce7-ty-nodes           = string,
    eks_cluster_autoscaler = string,
    oidc-role-policy-name  = string
  })

  default = {
    "eks_role"               = "ce7-grp-1-ty-eks-role",
    "ce7-ty-nodes"           = "ce7-grp-1-ty-node-group-nodes",
    "eks_cluster_autoscaler" = "ce7-grp-1-ty-eks-cluster-autoscaler"
    "oidc-role-policy-name"  = "ce7-grp-1-ty-eks-oidc-role-policy"
  }
}

# variable "kube_sa_info" {
#   description = "Variables for kubernetes service account creationa and policy attachment"
#   type = object({
#     kube_sa_name      = string,
#     kube_sa_namespace = string
#   })

#   default = {
#     "kube_sa_name"      = "kube-oidc",
#     "kube_sa_namespace" = "default"
#   }
# }

variable "eks_launch_template" {
  description = "launch template for eks node group"
  type = object({
    template_instance_type = string,
    template_name          = string,
    instance_tag_name      = string
  })
  default = {
    "template_instance_type" = "t3.medium",
    "template_name"          = "ce7-grp-1-ty-eks-launch-template",
    "instance_tag_name"      = "ce7-grp-1-ty-eks-node-group"
  }
}

variable "user_list" {
  description = "User within the same account"
  type        = list(string)
  default     = ["lcchua7", "stphntn", "junjie24"]
}
