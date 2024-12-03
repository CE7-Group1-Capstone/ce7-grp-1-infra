# data "terraform_remote_state" "terra-state" {
#   backend = "s3"
#   config = {
#     bucket = "<BUCKET_NAME>"
#     key    = "<BUCKET_KEY>" #Change the value of this to <your suggested name>.tfstate for  example
#     region = "<REGION>"
#   }
# }

data "aws_caller_identity" "current" {}