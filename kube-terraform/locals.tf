locals {
  OIDC                 = replace(data.aws_eks_cluster.ce7-ty-eks.identity[0].oidc[0].issuer, "https://", "")
  eks_cluster_endpoint = data.aws_eks_cluster.ce7-ty-eks.endpoint
  eks_cluster_ca_cert  = data.aws_eks_cluster.ce7-ty-eks.certificate_authority[0].data
  eks_cluster_name     = data.aws_eks_cluster.ce7-ty-eks.id
  eks_version          = data.aws_eks_cluster.ce7-ty-eks.version
}