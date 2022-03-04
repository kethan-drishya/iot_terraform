module "iot_thing" {
  source       = "../iot_thing/"
  iot_thing_ids  = var.iot_thing_ids
}

module "sns" {
  source       = "../sns/"
  email  = var.email
  topic_name = var.topic_name
  s3_bucket_name  = var.s3_bucket_name
}
