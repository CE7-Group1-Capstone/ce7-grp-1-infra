# Print out the private key
# output "vpc-module-info" {
#   value = length(var.vpc_config["pri-subnets"])
#   #   value = module.vpc.private_subnets
#   #   value = module.vpc.private_subnets[count]
# }

# output "priv-route-table-ids" {
#   value = module.vpc.default_security_group_id
# }
# output "ecs_config" {
#   value = var.eks_clusr_conf
# }
# output "def_tags" {
#   value = var.def_tags
# }
# output "instance_info" {
#     #value = module.ec2_instance.id
#     #value = module.ec2_instance.public_ip
#     value = 'ssh -i ${var.ec2_tf_key_name}.pem ec2-user@${module.ec2_instance.public_ip}'
# }

# output "tfstate_info" {
#   value = data.terraform_remote_state.terra-state.outputs
# }

# output "eks_name" {
#   value = aws_eks_cluster.ce7-ty.name
# }

# output "eks_role_arn" {
#   value = aws_iam_role.eks_role.arn
# }

# output "kube_sa_name" {
#   value = var.kube_sa_info.kube_sa_name
# }

# output "kube_sa_namespace" {
#   value = var.kube_sa_info.kube_sa_namespace
# }