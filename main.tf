provider "aws" {
  region = "us-east-2"
}

variable "setup_cert_manager" {
  description = "Flag creating cert-manager"
  type        = bool
  default     = true
}

resource "random_id" "cert_manager_route53_random_id" {
  count = var.setup_cert_manager ? 1 : 0
  byte_length = 8
}

resource "aws_iam_policy" "cert_manager_route53_iam_policy" {
  count = var.setup_cert_manager ? 1 : 0
  name = "cert_manager_route53_iam_policy-${resource.random_id.cert_manager_route53_random_id.0.id}"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/*"
    },
    {
      "Effect": "Allow",
      "Action": "route53:ListHostedZonesByName",
      "Resource": "*"
    }
  ]
}
EOF
}

output "cert_manager_route53_iam_policy" {
  value = aws_iam_policy.cert_manager_route53_iam_policy.0.id
}
