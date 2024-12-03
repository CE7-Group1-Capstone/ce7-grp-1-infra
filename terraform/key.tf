# resource "aws_key_pair" "deployer" {
#   key_name   = "${var.sshkey_name}-${formatdate("YYYYMMDDhhmm", timestamp())}"
#   public_key = "<EC2_PUB_KEY>"
# }