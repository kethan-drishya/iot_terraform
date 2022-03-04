variable "iot_thing_ids" {
  type    = string
  default = "1"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

variable "email" {
  type = string
  default = "kethan.sarma@drishya.ai"
} 

variable "topic_name" {
  type = string
  default = "iot_topic_1"
} 

variable "s3_bucket_name" {
  type = string
  default = "brains-hipvap-dev-s3"
} 

