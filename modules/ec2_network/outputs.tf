output "module_complete_simplistic" {
  value = null_resource.module_is_complete.id
}

# This is better, because it provides a "lineage".
output "module_complete" {
  value = "${var.module_dependency}${var.module_dependency == "" ? "" : "->"}${var.module_name}(${null_resource.module_is_complete.id})"
}

output vpc_id {
    value = aws_vpc.default.id
}

output subnet1_id {
    value = aws_subnet.subnet1.id
}

output subnet2_id {
    value = aws_subnet.subnet2.id
}