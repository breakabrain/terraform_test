################### variables
variable "region" {
  default = {
    testing    = "eu-central-1"
    staging    = "eu-west-1"
    production = "eu-west-2"
  }
}

variable "vpc_id" {
  default = {
    testing    = "vpc-9a8b49f0"
    staging    = "vpc-55bd512c"
    production = "vpc-38dca250"
  }
}

variable "subnet_ids" {
  default = {
    testing    = ["subnet-b019f8cc", "subnet-1b15e157"]
    staging    = ["subnet-082c0540", "subnet-a5940fff"]
    production = ["subnet-2beeae42", "subnet-b5cd1ff9"]
  }
}

variable "instance_type" {
  default = {
    testing    = "t2.micro"
    staging    = "t2.micro"
    production = "t2.micro"
  }
}

variable "image_id" {
  default = {
    testing    = "ami-07cda0db070313c52"
    staging    = "ami-0713f98de93617bb4"
    production = "ami-0089b31e09ac3fffc"
  }
}

variable "ssh_key" {
  description = "public ssh key for bastion"
  default = {
    testing    = "./testing-key-openssh.pub"
    staging    = "./staging-key-openssh.pub"
    production = "./production-key-openssh.pub"
  }
}
####################### end of list variables
