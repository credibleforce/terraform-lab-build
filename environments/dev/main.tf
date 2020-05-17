resource "null_resource" "module_dependency" {
  triggers = {
    dependency = var.module_dependency
  }
}

resource "aws_key_pair" "auth" {
    depends_on          = [null_resource.module_dependency]
    key_name            = var.key_name
    public_key          = file(var.public_key_path)
}

resource "null_resource" "module_is_complete" {
  depends_on = [aws_key_pair.auth]

  provisioner "local-exec" {
    command = "echo Module is complete: ${var.module_name}___"
  }
}