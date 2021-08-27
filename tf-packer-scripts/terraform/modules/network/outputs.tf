output "vpc_id" {
  value = huaweicloud_vpc.vpc_moodle.id
}

output "network_id_app" {
  value = huaweicloud_vpc_subnet.subnet_app_moodle.id
}

output "network_id_db" {
  value = huaweicloud_vpc_subnet.subnet_db_moodle.id
}

output "secgroup_name_app" {
  value = huaweicloud_networking_secgroup.secgroup_app_moodle.name
}

output "secgroup_name_db" {
  value = huaweicloud_networking_secgroup.secgroup_db_moodle.name
}

output "elb_eip_address" {
  value = huaweicloud_vpc_eip.eip_elb.publicip.0.ip_address
}

output "pool_id" {
  value = huaweicloud_lb_pool.group_moodle.id
}

output "listener_protocol_port" {
  value = huaweicloud_lb_listener.listener_moodle.protocol_port
}