output "module_complete_simplistic" {
  value = null_resource.module_is_complete.id
}

output "elb_certs" {
  value = aws_acm_certificate.cert
}

output "elb" {
  value = aws_lb.load_balancer
}

output "instance_record" {
  value = aws_route53_record.instance_record
}

output "elb_record" {
  value = aws_route53_record.elb_record
}

# This is better, because it provides a "lineage".
output "module_complete" {
  value = "${var.module_dependency}${var.module_dependency == "" ? "" : "->"}${var.module_name}(${null_resource.module_is_complete.id})"
}
    