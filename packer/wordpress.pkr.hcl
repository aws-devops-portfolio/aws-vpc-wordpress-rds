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

  post-processor "manifest" {
    output     = "packer-manifest.json"
    strip_path = true
  }

  post-processor "shell-local" {
    inline = [
     "set -e",
      "AMI_ID=$(jq -r '.builds[-1].artifact_id' packer-manifest.json | cut -d\":\" -f2)",
      "echo \"Resolved AMI_ID=$AMI_ID\"",
      "test -n \"$AMI_ID\"",
      "aws ssm put-parameter --name /ami/wordpress/latest --type String --value \"$AMI_ID\" --overwrite"
    ]
  }
}
