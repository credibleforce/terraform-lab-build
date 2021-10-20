output "module_complete_simplistic" {
  value = null_resource.module_is_complete.id
}

# This is better, because it provides a "lineage".
output "module_complete" {
  value = "${var.module_dependency}${var.module_dependency == "" ? "" : "->"}${var.module_name}(${null_resource.module_is_complete.id})"
}

output records {
    value = aws_route53_record.record
}

output certs {
    value = aws_acm_certificate.cert
}
    