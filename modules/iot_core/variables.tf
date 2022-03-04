variable "iot_thing_ids" {
  type    = string
  description = "Unique Names/ids of iot things in a list"
  #default = ["1"]
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}