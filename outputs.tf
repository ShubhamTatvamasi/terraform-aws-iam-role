output "cert_manager_route53_iam_policy" {
  value = var.setup_cert_manager ? aws_iam_policy.cert_manager_route53_iam_policy.0.arn : null
}

output "cert_manager_route53_iam_role" {
  value = var.setup_cert_manager ? aws_iam_role.cert_manager_route53_iam_role.0.arn : null
}
