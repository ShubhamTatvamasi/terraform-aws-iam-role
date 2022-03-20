variable "setup_cert_manager" {
  description = "Flag creating cert-manager"
  type        = bool
  default     = true
}

resource "random_id" "cert_manager_route53_random_id" {
  count       = var.setup_cert_manager ? 1 : 0
  byte_length = 8
}

resource "aws_iam_policy" "cert_manager_route53_iam_policy" {
  count = var.setup_cert_manager ? 1 : 0
  name  = "cert_manager_route53_iam_policy-${resource.random_id.cert_manager_route53_random_id.0.id}"
  path  = "/"

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

data "aws_iam_policy_document" "cert_manager_route53_iam_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type       = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cert_manager_route53_iam_role" {
  count               = var.setup_cert_manager ? 1 : 0
  name                = "cert_manager_route53_iam_role-${resource.random_id.cert_manager_route53_random_id.0.id}"
  assume_role_policy  = data.aws_iam_policy_document.cert_manager_route53_iam_policy_document.json
  managed_policy_arns = [aws_iam_policy.cert_manager_route53_iam_policy.0.arn]
}

output "cert_manager_route53_iam_policy" {
  value = var.setup_cert_manager ? aws_iam_policy.cert_manager_route53_iam_policy.0.arn : null
}

output "cert_manager_route53_iam_role" {
  value = var.setup_cert_manager ? aws_iam_role.cert_manager_route53_iam_role.0.arn : null
}
