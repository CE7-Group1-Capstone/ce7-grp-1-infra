# data "aws_s3_object" "eks" {
#   bucket = "<BUCKET_NAME>"
#   key    = "<BUCKET_KEY>"
# }

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "ce7-ty-eks" {
  name = var.cluster_name
}

data "aws_iam_policy" "external-dns" {
  name = var.externaldns_policy_name
}

# data "aws_eks_cluster" "eks_cluster" {
#   name = local.eks_cluster_name
# }

# data "terraform_remote_state" "infra-tfstate" {
#   backend = "s3"
#   config = {
#     bucket = "<BUCKET_NAME>"
#     key    = "<BUCKET_KEY>" // Path to state file within this bucket
#     region = "us-east-1"    // Change this to the appropriate region
#   }
# }