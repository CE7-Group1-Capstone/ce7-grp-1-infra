# Print out the private key
# output "vpc-module-info" {
#   value = length(var.vpc_config["pri-subnets"])
#   #   value = module.vpc.private_subnets
#   #   value = module.vpc.private_subnets[count]
# }

# output "remote_tfstate" {
#   value = data.terraform_remote_state.eks
# }

# output "account-id" {
#   value = data.aws_caller_identity.ACC_ID
# }

# output "externaldns-role-arn" {
#   value = aws_iam_role.helm-external-dns.arn
# }

# output "externaldns-sa-name" {
#   value = aws_iam_role.helm-external-dns.name
# }

# output "externaldns-role-namespace" {
#   value = var.role_namespace
# }

output "infra-tfstate" {
  value = data.aws_eks_cluster.ce7-ty-eks
}

# output "s3-remote_tfstate" {
#   # value = data.aws_s3_object.eks
#   value = local.eks_tfstate.resources[2].instances[0].attributes.endpoint
# }
# output "ecs_config" {
#   value = var.eks_clusr_conf
# }
# output "def_tags" {
#   value = var.def_tags
# }
# # output "instance_info" {
# #     #value = module.ec2_instance.id
# #     #value = module.ec2_instance.public_ip
# #     value = 'ssh -i ${var.ec2_tf_key_name}.pem ec2-user@${module.ec2_instance.public_ip}'
# # }

# # output "tfstate_info" {
# #   value = data.terraform_remote_state.terra-state.outputs
# # }

# output "eks_name" {
#   value = aws_eks_cluster.ce7-ty.name
# }