resource "aws_sns_topic" "iottest_topic" {
  name = var.topic_name
}

resource "aws_sns_topic" "myerrortopic" {
  name = "myerrortopic"
}


# Subscribe to sns topic with endpoint of our phone number
resource "aws_sns_topic_subscription" "iottest_notification_target" {
  topic_arn = aws_sns_topic.iottest_topic.arn
  protocol  = "email"
  endpoint  = var.email
}

# Create iot topic rule that forwards all iot messages to sns
resource "aws_iot_topic_rule" "iottest_topic_rule" {
  name = var.topic_name
  enabled = true
  sql_version =  "2016-03-23"
  sql = "SELECT * FROM 'iottest_topic'" #'devices/${aws_iot_thing.thing1.name}/data'

#  sns {
#     message_format = "RAW"
#     role_arn       = aws_iam_role.iottest_role.arn
#     target_arn     = aws_sns_topic.iottest_topic.arn
#     }
 s3 {
    bucket_name = var.s3_bucket_name
    key = "$${topic()}/data_$${timestamp()}.json"
    role_arn = "${aws_iam_role.iottest_role_sns.arn}"
    # target_arn = aws_sns_topic.iottest_topic.arn
  }
  error_action {
    sns {
      message_format = "JSON"
      role_arn       = aws_iam_role.iottest_role_sns.arn
      target_arn     = aws_sns_topic.myerrortopic.arn
      }
  }
}

# The role for the sns topic
resource "aws_iam_role" "iottest_role_sns" {
  name = "topic1iottestRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "iot.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Policy that allows our iot thing to access our sns topic
resource "aws_iam_role_policy" "iottest_role_policy_sns" {
  name = "iottest_sns_policy"
  role = aws_iam_role.iottest_role_sns.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "sns:Publish"
        ],
        "Resource": "${aws_sns_topic.iottest_topic.arn}"
    }
  ]
}
EOF
}