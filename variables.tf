variable "public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa_new.pub"
}


variable "aws_region" {
  type    = string
  default = "eu-central-1"
}


variable "instance_type" {
  type    = string
  default = "t3.micro"
}


variable "allow_port" {
  type    = list(number)
  default = [80, 443, 22]
}


variable "common_tags" {
  type = map(string)
  default = {
    Owner   = "Richard"
    Project = "Terraform"
  }
}
