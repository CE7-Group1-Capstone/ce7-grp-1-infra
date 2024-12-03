# IAM role for eks

resource "aws_iam_role" "eks_role" {
  name = var.iam_conf["eks_role"]
  tags = {
    Environment = var.def_tags["environment"]
    Name        = var.def_tags["Name"]
  }

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "eks.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

# resource "aws_iam_role" "eks_role" {
#   name = var.iam_conf["eks_role"]
#   tags = var.def_tags

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRoleWithWebIdentity",
#         Effect = "Allow",
#         Principal = {
#           Federated = aws_iam_openid_connect_provider.eks.arn
#         }
#       }
#     ]
#   })
# }

# eks policy attachment

resource "aws_iam_role_policy_attachment" "ce7-ty-EKSClusterPolicy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


resource "aws_iam_role" "ce7-ty-nodes" {
  name = var.iam_conf["ce7-ty-nodes"]

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# IAM policy attachment to nodegroup

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.ce7-ty-nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.ce7-ty-nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.ce7-ty-nodes.name
}

# IAM ODIC
data "tls_certificate" "eks" {
  url = aws_eks_cluster.ce7-ty.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.ce7-ty.identity[0].oidc[0].issuer
}

# resource "aws_iam_role_policy" "ce7-eks-oidc-policy" {
#   name = var.iam_conf["oidc-role-policy-name"]

#   role = aws_iam_role.eks_role.name

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRoleWithWebIdentity",
#         Effect = "Allow",
#         Principal = {
#           Federated = aws_iam_openid_connect_provider.eks.arn
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "eks_cluster_oidc_attach" {
#   role       = aws_iam_role.eks_role.arn
#   policy_arn = aws_iam_role_policy.ce7-eks-oidc-policy.arn
# }

# IAM Auto Scaling
data "aws_iam_policy_document" "eks_cluster_autoscaler_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:ce7-ty-kube:cluster-autoscaler"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_cluster_autoscaler" {
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_autoscaler_assume_role_policy.json
  name               = var.iam_conf["eks_cluster_autoscaler"]
}

resource "aws_iam_policy" "eks_cluster_autoscaler" {
  name = var.iam_conf["eks_cluster_autoscaler"]

  policy = jsonencode({
    Statement = [{
      Action = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_autoscaler_attach" {
  role       = aws_iam_role.eks_cluster_autoscaler.name
  policy_arn = aws_iam_policy.eks_cluster_autoscaler.arn
}

output "eks_cluster_autoscaler_arn" {
  value = aws_iam_role.eks_cluster_autoscaler.arn
}