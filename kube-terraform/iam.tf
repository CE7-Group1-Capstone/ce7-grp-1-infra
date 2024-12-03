resource "aws_iam_role" "helm-external-dns" {
  name = var.externaldns_role_name
  tags = var.def_tags

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.OIDC}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.OIDC}:sub" : join(":", ["system:serviceaccount", var.externaldns_info["namespace"], var.externaldns_info["release_name"]])
            # "${local.OIDC}:sub" : "system:serviceaccount:${var.externaldns_info["namespace"]}:external-dns"
            "${local.OIDC}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external-dns" {
  role       = aws_iam_role.helm-external-dns.name
  policy_arn = data.aws_iam_policy.external-dns.arn
}



# resource "aws_iam_role" "grafana_cloudwatch_iam_role" {
#   name = var.grafana_cloudwatch_role_name

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Principal = {
#           Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/${local.OIDC}"
#         }
#         Condition = {
#           StringEquals = {
#             "oidc.eks.eu-west-1.amazonaws.com/id/${local.OIDC}:sub" = "system:serviceaccount:prometheus:prometheus-grafana",
#             "oidc.eks.eu-west-1.amazonaws.com/id/${local.OIDC}:aud" = "sts.amazonaws.com"
#           }
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "grafana_cloudwatch_permissions" {
#   role       = aws_iam_role.grafana_cloudwatch_iam_role.name
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
# }

resource "aws_iam_role" "cloudwatch_role" {
  name               = "ce7-grp-1-eks-addon-role-${local.eks_cluster_name}-us-east-1"
  path               = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.OIDC}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${local.OIDC}:aud": "sts.amazonaws.com",
                    "${local.OIDC}:sub": "system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"
                }
            }
        }
    ]
}
EOF
}

## Attach policy 
resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.cloudwatch_role.name
}