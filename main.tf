provider "aws" {
    region = var.region[terraform.workspace]
}

resource "aws_key_pair" "key_for_bastion" {
    key_name = "key_for_bastion"
    public_key = file(var.ssh_key[terraform.workspace])
    tags = {
        Name = "${terraform.workspace}-terraform"
    }
}

resource "aws_eip" "eip_bastion" {
    vpc = true
    tags = {
        Name = "${terraform.workspace}-terraform"
    }
}

resource "aws_iam_role" "ir_bastion" {
  name = "ir_bastion"
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
  name = "irp_bastion-EIPAttachPolicy"
  role = aws_iam_role.ir_bastion.name
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

resource "aws_security_group" "ssh-only" {
    name = "ssh-only"
    description = "ssh-only"
    vpc_id = var.vpc_id[terraform.workspace]
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
        Name = "${terraform.workspace}-terraform"
    }
}

resource "aws_launch_configuration" "lc_bastion" {
    name = "lc_bastion"
    image_id = var.image_id[terraform.workspace]
    instance_type = var.instance_type[terraform.workspace]
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
        region = var.region[terraform.workspace]
    })
}

resource "aws_autoscaling_group" "ag_bastion" {
    name = "ag_bastion"
    max_size = 1
    min_size = 1
    desired_capacity = 1
    health_check_type = "EC2"
    launch_configuration = aws_launch_configuration.lc_bastion.name
    vpc_zone_identifier = var.subnet_ids[terraform.workspace]
    default_cooldown = "10"
    tag  {
        key = "Name"
        value = "${terraform.workspace}-terraform"
        propagate_at_launch = true
    }
}
