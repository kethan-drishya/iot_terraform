
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
} 
provider "aws" {
  region = "us-west-2"

  # Allow any 2.x version of the AWS provider
}

resource "aws_iot_thing" "test_iot_thing" {
  # for_each = toset(var.iot_thing_ids)

  name = "iot-${var.iot_thing_ids}"
}

# A policy for the iot thing that allowes external iot device inbound
resource "aws_iot_policy" "test_policy" {
  name = "iottest"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iot:Connect",
        "iot:Subscribe"
      ],
      "Resource": "arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iot:Publish"
      ],
      "Resource": "arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/test"
    }
  ]
}
EOF
}

# Create an aws iot certificate
resource "aws_iot_certificate" "test_cert" {
  csr    = file("csr.pem")
  active = true
}

# Attach policy generated above to the aws iot thing(s)
resource "aws_iot_policy_attachment" "test_policy_att" {
 

  policy = aws_iot_policy.test_policy.name
  target = aws_iot_certificate.test_cert.arn
}


# Output certificate to /cert/{IMSI} folder
resource "local_file" "test_cert_pem" {
  

  content     = aws_iot_certificate.test_cert.certificate_pem
  filename = "${path.cwd}/certs/${var.iot_thing_ids}/${substr(aws_iot_certificate.test_cert.id,0,12)}.pem.crt"

}

# Output private key to /cert/{IMSI} folder
resource "local_file" "test_private_key" {
  

  content     = aws_iot_certificate.test_cert.private_key
  filename = "${path.cwd}/certs/${var.iot_thing_ids}/${substr(aws_iot_certificate.test_cert.id,0,12)}.private.key"

}

# Output public key to /cert/{IMSI} folder
resource "local_file" "test_public_key" {
 

  content     = aws_iot_certificate.test_cert.public_key
  filename = "${path.cwd}/certs/${var.iot_thing_ids}/${substr(aws_iot_certificate.test_cert.id,0,12)}.public.key"

}

# Attach AWS iot cert generated above to the aws iot thing(s) 
resource "aws_iot_thing_principal_attachment" "test_principal_att" {
 

  principal = aws_iot_certificate.test_cert.arn
  thing     = aws_iot_thing.test_iot_thing.name
}

# Get the aws iot endpoint to print out for reference
data "aws_iot_endpoint" "endpoint" {
    endpoint_type = "iot:Data-ATS"
}

# Output arn of iot thing(s) 
output "iot_endpoint" {
  value = data.aws_iot_endpoint.endpoint.endpoint_address
}

# resource "aws_iot_certificate" "cert" {
#   csr    = file("csr.pem")
#   active = true
# }

resource "aws_iot_thing_principal_attachment" "att" {
  principal = aws_iot_certificate.test_cert.arn
  thing     = aws_iot_thing.example.name
}

resource "aws_acmpca_certificate" "example" {
  certificate_authority_arn   = aws_acmpca_certificate_authority.example.arn
  certificate_signing_request = tls_cert_request.csr.cert_request_pem
  signing_algorithm           = "SHA256WITHRSA"
  validity {
    type  = "YEARS"
    value = 1
  }
}

resource "aws_acmpca_certificate_authority" "example" {
  private_certificate_configuration {
    key_algorithm     = "RSA_4096"
    signing_algorithm = "SHA512WITHRSA"

    subject {
      common_name = "example.com"
    }
  }

  permanent_deletion_time_in_days = 7
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "tls_cert_request" "csr" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.key.private_key_pem

  subject {
    common_name = "example"
  }
}

