terraform {
  required_version = "~> 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    # helm = {
    #   source  = "hashicorp/helm"
    #   version = "~> 2.16"
    # }
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
  # default_tags {
  #   tags = {
  #     Environment = var.def_tags["environment"]
  #     Name        = var.def_tags["Name"]
  #   }
  # }
}

# provider "helm" {
#   kubernetes {
#     host                   = aws_eks_cluster.ce7-ty.endpoint
#     cluster_ca_certificate = base64decode(aws_eks_cluster.ce7-ty.certificate_authority[0].data)
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.ce7-ty.id]
#       command     = "aws"
#     }
#   }
# }