resource "aws_eks_access_entry" "ce7-kube-access" {
  count         = length(var.user_list)
  cluster_name  = aws_eks_cluster.ce7-ty.name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.user_list[count.index]}"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "ce7-kube-access" {
  count         = length(var.user_list)
  cluster_name  = aws_eks_cluster.ce7-ty.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.user_list[count.index]}"

  access_scope {
    type = "cluster"
    # namespaces = ["example-namespace"]
  }
}