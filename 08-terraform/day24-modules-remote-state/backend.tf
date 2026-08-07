terraform {
  backend "s3" {
    bucket         = "alok-tfstate-1786075383"
    key            = "day24/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
