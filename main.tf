provider "aws" {}

################### variables
variable "vpc_id" {
    type = string
    default = "vpc-9a8b49f0"
}

variable "subnet_ids" {
    type = list(string)
    default = ["subnet-b019f8cc", "subnet-1b15e157"]
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "region" {
    type = string
    default = "eu-central-1"
}

variable "ssh_key" {
    description = "public ssh key for bastion"
    type = string
    default = "<put your public ssh key>"
}
####################### end of list variables

resource "aws_key_pair" "key_for_bastion" {
    key_name = "key_for_bastion"
    public_key = var.ssh_key
    tags = {
        Name = "terraform"
    }
}

resource "aws_eip" "eip_bastion" {
    vpc = true
    tags = {
        Name = "terraform"
    }
}

################## iam
resource "aws_iam_role" "ir_bastion" {
  name               = "ir_bastion"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "irp_bastion" {
  name   = "irp_bastion-EIPAttachPolicy"
  role   = aws_iam_role.ir_bastion.name
  policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "ec2:AssociateAddress"
              ],
              "Resource": "*"
          }
      ]
}
EOF
}

resource "aws_iam_instance_profile" "iip_bastion" {
  name = "iip_bastion"
  role = aws_iam_role.ir_bastion.name
}
#################### end iam

resource "aws_security_group" "ssh-only" {
    name = "ssh-only"
    description = "ssh-only"
    vpc_id = var.vpc_id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "terraform"
    }
}

resource "aws_launch_configuration" "lc_bastion" {
    name = "lc_bastion"
    image_id = "ami-07cda0db070313c52"
    instance_type = var.instance_type
    iam_instance_profile = aws_iam_instance_profile.iip_bastion.name
    associate_public_ip_address = false
    security_groups = [aws_security_group.ssh-only.id]
    enable_monitoring = false
    lifecycle {
        create_before_destroy = true
    }
    key_name = aws_key_pair.key_for_bastion.key_name
    user_data = templatefile("user_data.sh", {
        eip = aws_eip.eip_bastion.id,
        region = var.region
    })
}

resource "aws_autoscaling_group" "ag_bastion" {
    name = "ag_bastion"
    max_size = 1
    min_size = 1
    desired_capacity = 1
    health_check_type = "EC2"
    launch_configuration = aws_launch_configuration.lc_bastion.name
    vpc_zone_identifier = var.subnet_ids
    default_cooldown = "10"
    tag  {
        key = "Name"
        value = "terraform"
        propagate_at_launch = true
    }
}

