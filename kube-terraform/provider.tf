terraform {
  required_version = "~> 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}

# provider "tls" {
#   version = ">= 4.0"
#   alias   = "default"
# }

# Configure the AWS Provider
# Uncomment the region, access_key and secret_key if you are running locally
provider "aws" {
  region = "us-east-1" # Update accordingly
  #access_key = ""                     # Update accordingly
  #secret_key = ""                     # Update accordingly
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    host                   = local.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(local.eks_cluster_ca_cert)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.eks_cluster_name]
      command     = "aws"
    }
  }
}

# provider "helm" {
#   kubernetes {
#     host                   = data.aws_s3_object.eks.cluster.endpoint
#     cluster_ca_certificate = base64decode(data.aws_s3_object.eks.cluster.certificate_authority.0.data)
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["eks", "get-token", "--cluster-name", data.aws_s3_object.eks.cluster.name]
#       command     = "aws"
#     }
#   }
# }

provider "kubectl" {
  host                   = local.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(local.eks_cluster_ca_cert)
  # token                  = data.aws_eks_cluster_auth.main.token
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.eks_cluster_name]
    command     = "aws"
  }
  load_config_file = false
}