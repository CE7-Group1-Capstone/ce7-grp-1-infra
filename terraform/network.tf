module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = var.vpc_config["vpc_name"]
  cidr = "10.0.0.0/16"

  azs             = var.vpc_config["azs"]
  private_subnets = var.vpc_config["pri_subnets"]
  public_subnets  = var.vpc_config["pub_subnets"]

  enable_nat_gateway      = false
  enable_vpn_gateway      = false
  map_public_ip_on_launch = true

  tags = var.def_tags
}

resource "aws_vpc_endpoint" "s3-vpce" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = var.s3_vpce
  }
}

resource "aws_security_group" "ty-sg" {

  name        = var.sg_name
  description = var.sg_name
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = var.sg_name
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1" # semantically equivalent to all ports
  }
}

# For EKS
# module "vpc_cni_irsa" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version = "~> 5.0"

#   role_name_prefix      = "ce7-ty-cni-irsa"
#   attach_vpc_cni_policy = true
#   vpc_cni_enable_ipv4   = true

#   oidc_providers = {
#     main = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:aws-node"]
#     }
#   }
# }

# resource "aws_lb_target_group" "k8-tg" {
#   name     = "ce7-ty-tg"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = module.vpc.vpc_id
# }

# resource "aws_lb" "k8-lb" {
#   name               = "ce7-ty-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.ty-sg.id]
#   subnets            = module.vpc.public_subnets

#   tags = var.def_tags
# }

# resource "aws_lb_listener" "front_end" {
#   load_balancer_arn = aws_lb.k8-lb.arn
#   port              = "80"
#   protocol          = "HTTP"
#   # ssl_policy        = "ELBSecurityPolicy-2016-08"
#   # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.k8-tg.arn
#   }
# }