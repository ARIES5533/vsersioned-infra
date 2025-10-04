terraform {
  backend "s3" {
    bucket  = "my-terraform-state-bucket5533"
    key     = "ec2-infra/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true

    # enable native locking
    use_lockfile = true
  }
}
