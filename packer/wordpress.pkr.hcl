packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.2.0"
    }
  }
}

source "amazon-ebs" "wordpress" {
  region                  = "us-east-1"
  instance_type           = "t2.micro"
  ssh_username            = "ubuntu"
  ami_name                = "wordpress-ami-{{timestamp}}"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
}

build {
  sources = ["source.amazon-ebs.wordpress"]

  provisioner "shell" {
    script = "setup.sh"
    execute_command  = "sudo -E bash '{{ .Path }}'"
  }

  post-processor "shell-local" {
    inline = [
      <<-EOF
        aws ssm put-parameter \
        --name /ami/wordpress/latest \
        --type String \
        --value {{ (index .Builds 0).ArtifactId  | split ":" | last }} \
        --overwrite
      EOF
    ]
  }
}
