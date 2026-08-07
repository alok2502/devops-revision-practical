# call the module for DEV
module "dev_network" {
  source             = "./modules/vpc"
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  environment        = "dev"
}

# call the SAME module for STAGING — different values, same code
module "staging_network" {
  source             = "./modules/vpc"
  vpc_cidr           = "10.1.0.0/16"
  public_subnet_cidr = "10.1.1.0/24"
  environment        = "staging"
}
