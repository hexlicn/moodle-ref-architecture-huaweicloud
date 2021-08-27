#----mysql----
data "huaweicloud_availability_zones" "sa_az" {
    region = var.region
    state  = "available"
}

data "huaweicloud_dcs_az" "sa_az" {
  region = var.region
  code   = "af-south-1a"
}

// data "huaweicloud_vpc" "vpc_moodle" {
//   name = var.instance_vpc_id
// }

data "huaweicloud_vpc_subnet" "subnet_moodle_db" {
  id = var.network_id_db
}

data "huaweicloud_networking_secgroup" "moodle_secgroup_db" {
  name = var.instance_security_group
}

resource "random_password" "mypassword" {
  length           = 12
  special          = true
  override_special = "!@#%^*-_=+"
}

resource "huaweicloud_rds_instance" "mysql_moodle" {
  name                = "mysql_moodle"
  flavor              = "rds.mysql.c6.large.4.ha"
  ha_replication_mode = "async"
  vpc_id              = var.vpc_id
  subnet_id           = data.huaweicloud_vpc_subnet.subnet_moodle_db.id
  security_group_id   = data.huaweicloud_networking_secgroup.moodle_secgroup_db.id
  availability_zone   = [
    data.huaweicloud_availability_zones.sa_az.names[0],
    data.huaweicloud_availability_zones.sa_az.names[1]
  ]

  db {
    type     = "MySQL"
    version  = "5.7"
    password = random_password.mypassword.result
  }
  volume {
    type = "ULTRAHIGH"
    size = 40
  }
}

#----redis----
resource "huaweicloud_dcs_instance" "redis_moodle" {
  name            = "redis_moodle"
  engine          = "Redis"
  engine_version  = "5.0"
  password        = random_password.mypassword.result
  capacity        = 2
  vpc_id          = var.vpc_id
  subnet_id       = data.huaweicloud_vpc_subnet.subnet_moodle_db.id
  available_zones = [data.huaweicloud_dcs_az.sa_az.id]
  product_id      = "redis.ha.xu1.large.r2.2-h_2_1"

  backup_policy {
    save_days   = 1
    backup_type = "manual"
    begin_at    = "00:00-01:00"
    period_type = "weekly"
    backup_at   = [1, 2, 4, 6]
  }
}