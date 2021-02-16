data "aws_ami" "kali" {
    most_recent = true
    owners      = ["679593333241"]

    filter {
        name   = "name"
        values = ["kali-linux-2020.*"]
    }
}

data "aws_ami" "centos" {
  most_recent = true
  owners      = ["125523088429"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "name"
    values = ["CentOS 8.* x86_64*"]
  }
}

# Discover latest windows 2016 ami
data "aws_ami" "win16" {
  most_recent = true
  owners      = ["amazon","microsoft"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base-*"]
  }
}

resource "null_resource" "trusted-local-source" {
    provisioner "local-exec" {
        command = "echo $(dig +short @resolver1.opendns.com myip.opendns.com)/32 > /tmp/local-trusted-source.txt"
    }
}

data "local_file" "trusted-source" {
    filename = "/tmp/local-trusted-source.txt"
    depends_on = [null_resource.trusted-local-source]
}