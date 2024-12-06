# ce7-grp-1 EKS cluster
## Notice
Please read through the following repositories before proceeding on:
- [ML Model Training and Publishing](https://github.com/CE7-Group1-Capstone/capstone-mlops-project/blob/main/README.md)
  - [Part A](https://github.com/CE7-Group1-Capstone/capstone-mlops-project/blob/main/docs/getting_started_clc-A.md)
  - [Part B](https://github.com/CE7-Group1-Capstone/capstone-mlops-project/blob/main/docs/getting_started_clc-B.md)
- [Insurance Buying Prediction Application Deployment & Rollback](https://github.com/CE7-Group1-Capstone/capstone-mlops-project/blob/main/docs/getting_started_st.md)
- [Prometheus & Grafana SRE Monitoring Tools](https://github.com/CE7-Group1-Capstone/capstone-mlops-project/blob/main/docs/getting_started_jj.md)

## Summary
- This EKS cluster was deployed to serve as a kubernetes cluster for ce7-grp-1 MLOps project.
- Initial design was to deploy a production and dev cluster for deployments. However, due to limitations, it is decided to only have a single cluster for this project.
- To cater to the CI/CD component of the project 2 namespaces created in the cluster: _dev_ and _prod_.
- 2 main workflows are used to deploy the cluster, "Cluster infra check and apply" and "Kube config check and apply"
  - "Cluster infra check and apply"  : Create VPC, EKS cluster, and authorize listed IAM user to access the AWS cluster
  - "Kube config check and apply"    : Enable EKS Add-ons, Helm chart installations, and Kubectl apply of ingress rules.
- This repo only uses the following repo secrets and repo variable:
  - Repo Secrets:
    - AWS_SECRET_ACCESS_ID
    - AWS_SECRET_ACCESS_KEY
    - BUCKET_KEY
    - BUCKET_NAME
    - KUBE_BUCKET_KEY
    - KUBE_BUCKET_NAME
    - ECR_PRI_REPO_URI
  - Repo Variables:
    - EKS_REGION
  - *No environment secrets or variable are considering there is only cluster required for this project.


## Project Infrastructure overview
![ce7-grp-1-kubernetes drawio(5)](https://github.com/user-attachments/assets/f729954f-79c3-407c-865d-c2190577386f)



## Deployments via terraform
| S/N | Mode of deployment | Description | Function | Artefacthub/Terraform URL |
| --- | ---  | :--- | --- | --- |
| 1. | Helm Chart | ingress-nginx | Kubernetes cluster's reverse proxy and load balancer | https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx/4.11.3 |
| 2. | Helm Chart | external-dns | Creates AWS Route53 A records with reference to kubernetes ingress rules configured | https://artifacthub.io/packages/helm/external-dns/external-dns |
| 3. | Helm Chart | kube-prometheus-stack | Deploys Grafana, Prometheus and Alertmanager to gather metrics within cluster and visualize with grafana | https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack |
| 4. | Helm Chart | Loki-stack | Deploys Loki to gather logs from pods within cluster | https://artifacthub.io/packages/helm/grafana/loki-stack |
| 5. | Helm Chart (Terraform aws_eks_addon) | aws-cloudwatch-metrics | Enables Add-ons Couldwatch observability | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon |
| 6. | Helm Chart (Terraform aws_eks_addon) | metrics-server | Collects kubernetes node and pods metrics for administrator's view | https://registry.terraform.io/modules/aws-ia/eks-blueprints-addons/aws/latest |


## Monitoring Tools
### k9s
To get a better overview of the kubernetes cluster, we would recommend using k9s to monitor and also diagnose the cluster. This terminal based UI can provide the following informations:
- An overview of the pods in all namespaces with the resource usage of the respective pods.
  ![image](https://github.com/user-attachments/assets/db5c8a72-472e-455a-9a49-f967f3613421)
- Overview of the cluster status
  ![image](https://github.com/user-attachments/assets/9d8d31bf-7e81-41ff-b8b5-5e63034b9147)
- Pods dependencies
  ![image](https://github.com/user-attachments/assets/15735318-65b0-4911-8590-c5a6ba4bcfb0)

## AWS IAM User EKS administrator access
To allow AWS IAM users EKS administrator access to 
```terraform
variable "user_list" {
  description = "User within the same account"
  type        = list(string)
  default     = ["user1", "user2", "user3"]
}
```


## Adding Helm charts deployments
Any additional helm chart deployments can be simply added to the helm_info nested list variable located in variable.tf as show below:
```terraform
variable "helm_info" {
  description = "helm configurations"
  type        = list(list(string))

  default = [
    #Template for helm list object ["release", "repo_url", "chart", "create namespace (boolean)", "namespace", "value_path"]
    ["ce7-grp-1-nginx", "https://kubernetes.github.io/ingress-nginx", "ingress-nginx", "false", "default", ""],
    # ["ce7-grp-1-prome", "https://prometheus-community.github.io/helm-charts", "kube-prometheus-stack", "true", "monitoring", "/helm_values/prome-value.yaml"],
    ["ce7-grp-1-loki", "https://grafana.github.io/helm-charts", "loki-stack", "true", "loki", ""],
  ]
}
```
**Please take note that customized value files with static parameters can added to /helm_values/<customized_value>.yaml**


## The helm 
```terraform
resource "helm_release" "helm-install" {
  count            = length(var.helm_info)
  upgrade_install  = true
  force_update     = true
  create_namespace = tobool(var.helm_info[count.index][3])

  name       = var.helm_info[count.index][0]
  repository = var.helm_info[count.index][1]
  chart      = var.helm_info[count.index][2]
  namespace  = var.helm_info[count.index][4]

  values = (var.helm_info[count.index][5] == "" ? [] : [file("${path.cwd}${var.helm_info[count.index][5]}")])

  depends_on = [time_sleep.wait_30_seconds]
}
```

## Learnings
| S/N | Description | Details |
| --- | --- | --- |
| 1. | Create customized values,yaml | <ul><li>No need to edit the default values.yaml</li><li>Understand the paramenters in the default values.yaml and create a customized values.yaml</li><li>Customized parameters in customized value.yaml will override default values</li></ul> |
| 2. | Kubernetes cluster user acess configmap | k8s cluster access can be manually added to the cluster's configmap. However, we would recommend enable the api and configmap access control when deploying the cluster. Doing so will simplify the access by including the IAM user in the terraform code. <ul><li><pre>access_config {<br/>  authentication_mode                         = "API_AND_CONFIG_MAP"<br/>  bootstrap_cluster_creator_admin_permissions = true<br/>}</pre><li><pre>resource "aws_eks_access_entry" "ce7-kube-access" {<br/>  cluster_name  = aws_eks_cluster.ce7-ty.name<br/>  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.user_list[count.index]}"<br/>  type          = "STANDARD"<br/>}</pre><li><pre>resource "aws_eks_access_policy_association" "ce7-kube-access" {<br/>  cluster_name  = aws_eks_cluster.ce7-ty.name<br/>  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"<br/>  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.user_list[count.index]}"<br/>  access_scope {<br/>    type = "cluster"<br/>  }<br/>}</pre></ul>|

## Further improvement
| S/N | Description | Purpose |
| --- | --- | --- |
| 1. | Incorporate discord configuration into customized value.yaml | Discord configuration to be implemented every fresh deployment |
| 2. | Add PV and PVC for grafana and loki | Data retention even with Grafana or loki redeployed in cluster |
| 3. | Include customized dashboards into repo. | Remove the need to reconfigure customized dashboards after every kube-prometheus-stack redeployments |
| 4. | Implement alerts and include alert values in customized value.yaml | Include alert notifications and include alert limits in kube-prometheus-stack value.yaml |

## Credits
- Stephen Tan
- Chua Lai Chwang
- Jun Jie
- Tan Yuan


# Additional information on AWS EKS infrastructure terraform code
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.13.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_access_entry.ce7-kube-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_policy_association.ce7-kube-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association) | resource |
| [aws_eks_cluster.ce7-ty](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.ce7-ty-nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_openid_connect_provider.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.eks_cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ce7-ty-nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ce7-ty-EKSClusterPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_cluster_autoscaler_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.ce7-ty-node-template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.ty-sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_endpoint.s3-vpce](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint_route_table_association.priv-s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.eks_cluster_autoscaler_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [tls_certificate.eks](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_def_tags"></a> [def\_tags](#input\_def\_tags) | default tags | <pre>object({<br/>    Name        = string,<br/>    creator     = string,<br/>    environment = string<br/>  })</pre> | <pre>{<br/>  "Name": "ce7-grp-1-ty",<br/>  "creator": "ce7-grp-1-ty",<br/>  "environment": "dev"<br/>}</pre> | yes |
| <a name="input_eks_clusr_conf"></a> [eks\_clusr\_conf](#input\_eks\_clusr\_conf) | eks cluster configurations | <pre>object({<br/>    cluster_name       = string,<br/>    node_group_name    = string,<br/>    node_scale_desired = number,<br/>    node_scale_max     = number,<br/>    node_scale_min     = number,<br/>    max_unavail        = number,<br/>    node_name          = string<br/>  })</pre> | <pre>{<br/>  "cluster_name": "ce7-grp-1-eks",<br/>  "max_unavail": 1,<br/>  "node_group_name": "ce7-grp-1-eks-nodes",<br/>  "node_name": "ce7-grp-1-ty",<br/>  "node_scale_desired": 2,<br/>  "node_scale_max": 3,<br/>  "node_scale_min": 1<br/>}</pre> | yes |
| <a name="input_eks_launch_template"></a> [eks\_launch\_template](#input\_eks\_launch\_template) | launch template for eks node group | <pre>object({<br/>    template_instance_type = string,<br/>    template_name          = string,<br/>    instance_tag_name      = string<br/>  })</pre> | <pre>{<br/>  "instance_tag_name": "ce7-grp-1-ty-eks-node-group",<br/>  "template_instance_type": "t3.medium",<br/>  "template_name": "ce7-grp-1-ty-eks-launch-template"<br/>}</pre> | yes |
| <a name="input_iam_conf"></a> [iam\_conf](#input\_iam\_conf) | iam configurations requirements | <pre>object({<br/>    eks_role               = string,<br/>    ce7-ty-nodes           = string,<br/>    eks_cluster_autoscaler = string,<br/>    oidc-role-policy-name  = string<br/>  })</pre> | <pre>{<br/>  "ce7-ty-nodes": "ce7-grp-1-ty-node-group-nodes",<br/>  "eks_cluster_autoscaler": "ce7-grp-1-ty-eks-cluster-autoscaler",<br/>  "eks_role": "ce7-grp-1-ty-eks-role",<br/>  "oidc-role-policy-name": "ce7-grp-1-ty-eks-oidc-role-policy"<br/>}</pre> | yes |
| <a name="input_s3_vpce"></a> [s3\_vpce](#input\_s3\_vpce) | name of vpce for S3 | `string` | `"ce7-grp-1-ty-vpce-s3"` | yes |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | Name of Terraform EC2 security group | `string` | `"ce7-grp-1-ty-sg"` | yes |
| <a name="input_user_list"></a> [user\_list](#input\_user\_list) | User within the same account | `list(string)` | <pre>[<br/>  "lcchua7",<br/>  "stphntn",<br/>  "junjie24"<br/>]</pre> | yes |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | vpc config | <pre>object({<br/>    vpc_name    = string,<br/>    azs         = list(string),<br/>    pri_subnets = list(string),<br/>    pub_subnets = list(string)<br/>  })</pre> | <pre>{<br/>  "azs": [<br/>    "us-east-1a",<br/>    "us-east-1b"<br/>  ],<br/>  "pri_subnets": [<br/>    "10.0.1.0/24",<br/>    "10.0.2.0/24"<br/>  ],<br/>  "pub_subnets": [<br/>    "10.0.101.0/24",<br/>    "10.0.102.0/24"<br/>  ],<br/>  "vpc_name": "ce7-grp-1-vpc"<br/>}</pre> | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_cluster_autoscaler_arn"></a> [eks\_cluster\_autoscaler\_arn](#output\_eks\_cluster\_autoscaler\_arn) | n/a |


# Additional information on Kubernetes configuration terraform code
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.16 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 1.14 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.23 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.16 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | ~> 1.14 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.23 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.12 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_blueprints_addons"></a> [eks\_blueprints\_addons](#module\_eks\_blueprints\_addons) | aws-ia/eks-blueprints-addons/aws | ~> 1.19 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_iam_role.cloudwatch_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.helm-external-dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.external-dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [helm_release.externaldns](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.helm-install](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.prome](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.custom_rules](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.eks_ns](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [time_sleep.wait_30_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.ce7-ty-eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_iam_policy.external-dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | eks\_cluster\_name | `string` | `"ce7-grp-1-eks"` | yes |
| <a name="input_def_tags"></a> [def\_tags](#input\_def\_tags) | default tags | <pre>object({<br/>    creator     = string,<br/>    environment = string<br/>  })</pre> | <pre>{<br/>  "creator": "ce7-ty",<br/>  "environment": "dev"<br/>}</pre> | yes |
| <a name="input_externaldns_info"></a> [externaldns\_info](#input\_externaldns\_info) | n/a | <pre>object({<br/>    release_name    = string,<br/>    repo            = string,<br/>    chart           = string,<br/>    create_ns       = bool,<br/>    namespace       = string,<br/>    value_path      = string,<br/>    force_update    = bool,<br/>    upgrade_install = bool<br/>  })</pre> | <pre>{<br/>  "chart": "external-dns",<br/>  "create_ns": true,<br/>  "force_update": true,<br/>  "namespace": "default",<br/>  "release_name": "external-dns",<br/>  "repo": "https://kubernetes-sigs.github.io/external-dns/",<br/>  "upgrade_install": true,<br/>  "value_path": "/helm_values/templates/externaldns-rbac.yaml"<br/>}</pre> | yes |
| <a name="input_externaldns_policy_name"></a> [externaldns\_policy\_name](#input\_externaldns\_policy\_name) | externaldns\_policy\_name | `string` | `"AllowExternalDNSUpdates"` | yes |
| <a name="input_externaldns_role_name"></a> [externaldns\_role\_name](#input\_externaldns\_role\_name) | externaldns\_role\_name | `string` | `"ce7-ty-external-dns"` | yes |
| <a name="input_helm_info"></a> [helm\_info](#input\_helm\_info) | helm configurations | `list(list(string))` | <pre>[<br/>  [<br/>    "ce7-grp-1-nginx",<br/>    "https://kubernetes.github.io/ingress-nginx",<br/>    "ingress-nginx",<br/>    "false",<br/>    "default",<br/>    ""<br/>  ],<br/>  [<br/>    "ce7-grp-1-loki",<br/>    "https://grafana.github.io/helm-charts",<br/>    "loki-stack",<br/>    "true",<br/>    "loki",<br/>    ""<br/>  ]<br/>]</pre> | yes |
| <a name="input_mlops_info"></a> [mlops\_info](#input\_mlops\_info) | mlops configurations | <pre>object({<br/>    service_name = string,<br/>    namespaces   = list(string),<br/>    service_port = number,<br/>    url_name     = string,<br/>  })</pre> | <pre>{<br/>  "namespaces": [<br/>    "dev",<br/>    "prod"<br/>  ],<br/>  "service_name": "fast-api-service",<br/>  "service_port": 80,<br/>  "url_name": "mlops"<br/>}</pre> | yes |
| <a name="input_namespaces_names"></a> [namespaces\_names](#input\_namespaces\_names) | namespaces to be created | `list(string)` | <pre>[<br/>  "dev",<br/>  "prod",<br/>  "monitoring"<br/>]</pre> | yes |
| <a name="input_prome_info"></a> [prome\_info](#input\_prome\_info) | n/a | <pre>object({<br/>    release_name    = string,<br/>    repo            = string,<br/>    chart           = string,<br/>    create_ns       = bool,<br/>    namespace       = string,<br/>    value_path      = string,<br/>    force_update    = bool,<br/>    upgrade_install = bool<br/>  })</pre> | <pre>{<br/>  "chart": "kube-prometheus-stack",<br/>  "create_ns": true,<br/>  "force_update": true,<br/>  "namespace": "monitoring",<br/>  "release_name": "ce7-grp-1-prome",<br/>  "repo": "https://prometheus-community.github.io/helm-charts",<br/>  "upgrade_install": true,<br/>  "value_path": "/helm_values/prome-value.yaml"<br/>}</pre> | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_infra-tfstate"></a> [infra-tfstate](#output\_infra-tfstate) | n/a |
