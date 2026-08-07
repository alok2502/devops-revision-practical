output "dev_vpc_id" {
  value = module.dev_network.vpc_id       # <-- read the module's output
}
output "staging_vpc_id" {
  value = module.staging_network.vpc_id
}
