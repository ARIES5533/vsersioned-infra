terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = "AKIA6AIN7MI5S4IWOJZA"
  secret_key = "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"
}




resource "aws_instance" "testing" {
    instance_type = "t2.micro"
    ami = "ami-0360c520857e3138f"

    tags                                 = {
        "Name" = "Good"
    }


}



resource "aws_instance" "web1" {
    ami                                  = "ami-0360c520857e3138f"
    associate_public_ip_address          = true
    availability_zone                    = "us-east-1b"
    instance_type                        = "t2.micro"
    key_name                             = "ec2keypair"
    region                               = "us-east-1"
    tags                                 = {
        "Name" = "Passed"
    }
}    
 




