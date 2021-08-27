#----vpc----
resource "huaweicloud_vpc" "vpc_moodle" {
  name = var.vpc_name
  cidr = var.base_cidr_block
}

#----subnet-----
resource "huaweicloud_vpc_subnet" "subnet_app_moodle" {
  vpc_id      = huaweicloud_vpc.vpc_moodle.id
  name        = var.subnet_name_app
  cidr        = var.subnet_cidr_app
  gateway_ip  = var.subnet_gateway_ip_app
  primary_dns = var.primary_dns
}

resource "huaweicloud_vpc_subnet" "subnet_db_moodle" {
  vpc_id      = huaweicloud_vpc.vpc_moodle.id
  name        = var.subnet_name_db
  cidr        = var.subnet_cidr_db
  gateway_ip  = var.subnet_gateway_ip_db
  primary_dns = var.primary_dns
}

#----secgroup----
resource "huaweicloud_networking_secgroup" "secgroup_app_moodle" {
  name        = var.secgroup_name_app
  description = "security group for moodle app"
}

resource "huaweicloud_networking_secgroup" "secgroup_db_moodle" {
  name        = var.secgroup_name_db
  description = "security group for moodle db"
}

#----secgrouprule----
resource "huaweicloud_networking_secgroup_rule" "secgroup_rule_app" {
  count             = length(lookup(var.sgsapp[0], "rules"))
  direction         = lookup(lookup(var.sgsapp[0], "rules")[count.index], "direction")
  ethertype         = lookup(lookup(var.sgsapp[0], "rules")[count.index], "ethertype")
  protocol          = lookup(lookup(var.sgsapp[0], "rules")[count.index], "protocol")
  port_range_min    = lookup(lookup(var.sgsapp[0], "rules")[count.index], "port_range_min")
  port_range_max    = lookup(lookup(var.sgsapp[0], "rules")[count.index], "port_range_max")
  remote_ip_prefix  = lookup(lookup(var.sgsapp[0], "rules")[count.index], "remote_ip_cidr")
  security_group_id = huaweicloud_networking_secgroup.secgroup_app_moodle.*.id[0]
}

resource "huaweicloud_networking_secgroup_rule" "secgroup_rule_db" {
  count             = length(lookup(var.sgsdb[0], "rules"))
  direction         = lookup(lookup(var.sgsdb[0], "rules")[count.index], "direction")
  ethertype         = lookup(lookup(var.sgsdb[0], "rules")[count.index], "ethertype")
  protocol          = lookup(lookup(var.sgsdb[0], "rules")[count.index], "protocol")
  port_range_min    = lookup(lookup(var.sgsdb[0], "rules")[count.index], "port_range_min")
  port_range_max    = lookup(lookup(var.sgsdb[0], "rules")[count.index], "port_range_max")
  remote_ip_prefix  = lookup(lookup(var.sgsdb[0], "rules")[count.index], "remote_ip_cidr")
  security_group_id = huaweicloud_networking_secgroup.secgroup_db_moodle.*.id[0]
}

#----eip----
resource "huaweicloud_vpc_eip" "eip_elb" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "bandwidth-elb-moodle"
    size        = 1
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

#----elb----
resource "huaweicloud_lb_loadbalancer" "elb_moodle" {
  name          = var.loadbalancer_name
  description   = "elb for moodle"
  vip_subnet_id = huaweicloud_vpc_subnet.subnet_app_moodle.subnet_id
}

#----associate eip with loadbalancer----
resource "huaweicloud_networking_eip_associate" "associate_moodle_eip" {
  public_ip = huaweicloud_vpc_eip.eip_elb.address
  port_id   = huaweicloud_lb_loadbalancer.elb_moodle.vip_port_id
}

resource "huaweicloud_lb_listener" "listener_moodle" {
  name            = "moodle_elb_listener_http"
  protocol        = "HTTP"
  protocol_port   = 80
  loadbalancer_id = huaweicloud_lb_loadbalancer.elb_moodle.id
}

resource "huaweicloud_lb_pool" "group_moodle" {
  name        = "group_moodle"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = huaweicloud_lb_listener.listener_moodle.id
}

resource "huaweicloud_lb_monitor" "health_check" {
  name           = "health_check"
  type           = "HTTP"
  url_path       = "/"
  expected_codes = "200-202"
  delay          = 10
  timeout        = 5
  max_retries    = 3
  pool_id        = huaweicloud_lb_pool.group_moodle.id
}

resource "huaweicloud_lb_member" "member_1" {
  address       = var.instance_addr1
  protocol_port = 80
  weight        = 1
  pool_id       = huaweicloud_lb_pool.group_moodle.id
  subnet_id     = huaweicloud_vpc_subnet.subnet_app_moodle.subnet_id
}

resource "huaweicloud_lb_member" "member_2" {
  address       = var.instance_addr2
  protocol_port = 80
  weight        = 1
  pool_id       = huaweicloud_lb_pool.group_moodle.id
  subnet_id     = huaweicloud_vpc_subnet.subnet_app_moodle.subnet_id
}