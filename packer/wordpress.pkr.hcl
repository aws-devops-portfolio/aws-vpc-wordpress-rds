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
      "AMI_ID='{{ build.ArtifactId }}'",
      "AMI_ID=$(echo \"$PACKER_ARTIFACT_ID\" | cut -d':' -f2)",
      "test -n \"$AMI_ID\" || (echo 'AMI ID is empty' && exit 1)",
      "aws ssm put-parameter --name /ami/wordpress/latest --type String --value \"$AMI_ID\" --overwrite"
    ]
  }
}
