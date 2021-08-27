#----configure HuaweiCloud Provider----
provider "huaweicloud" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

#----configure network module----
module "network" {
  source            = "./modules/network"
  vpc_name          = "vpc-${var.env}"
  base_cidr_block   = "172.16.0.0/16"
  subnet_name_app   = "subnet-${var.env}-app"
  subnet_name_db    = "subnet-${var.env}-db"
  secgroup_name_app = "sg-${var.env}-app"
  secgroup_name_db  = "sg-${var.env}-db"
  instance_addr1    = module.instance.instance_priv_addr1
  instance_addr2    = module.instance.instance_priv_addr2
}

#----configure vm instance module----
module "instance" {
  source                  = "./modules/instance"
  vpc_id                  = module.network.vpc_id
  network_id_app          = module.network.network_id_app
  instance_security_group = module.network.secgroup_name_app
  elb_pool_id             = module.network.pool_id
  elb_listener_port       = module.network.listener_protocol_port
}

#----configure mysql & redis instance module----
module "database" {
  source                  = "./modules/database"
  vpc_id                  = module.network.vpc_id
  network_id_db           = module.network.network_id_db
  instance_security_group = module.network.secgroup_name_db
}

