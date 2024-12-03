module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.19"

  cluster_name      = local.eks_cluster_name
  cluster_endpoint  = local.eks_cluster_endpoint
  cluster_version   = local.eks_version
  oidc_provider_arn = local.OIDC

  enable_metrics_server         = true
  enable_aws_cloudwatch_metrics = true
  #   enable_cluster_proportional_autoscaler = true
  #   enable_karpenter = true
  #   enable_aws_for_fluentbit = true
  #   aws_for_fluentbit = {
  #     enable_containerinsights = true
  #   }

  tags = {
    Environment = "ce7-grp-1-infra"
  }
}

# resource "aws_eks_addon" "eks_addon" {
#   cluster_name = local.eks_cluster_name
#   addon_name   = "amazon-cloudwatch-observability"
# }

resource "aws_eks_addon" "cloudwatch" {
  cluster_name = local.eks_cluster_name
  addon_name   = "amazon-cloudwatch-observability"
  #   addon_version               = var.cloudwatch_addon_version
  service_account_role_arn    = aws_iam_role.cloudwatch_role.arn
  resolve_conflicts_on_update = "OVERWRITE"
  configuration_values = jsonencode({
    containerLogs = {
      enabled = true
    },
    agent = {
      config = {
        logs = {
          metrics_collected = {
            application_signals = {},
            kubernetes = {
              "enhanced_container_insights" : true
              "accelerated_compute_metrics" : false
            }
          }
        }
      }
    }
  })
}