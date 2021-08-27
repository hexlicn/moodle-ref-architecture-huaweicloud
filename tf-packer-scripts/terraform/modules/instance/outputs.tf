output "az_name" {
  value = data.huaweicloud_availability_zones.sa_az.names
}

output "instance_flavor" {
  value = data.huaweicloud_compute_flavors.moodle_flavor.ids
}

output "instance1_status" {
  value = huaweicloud_compute_instance.instance[0].status
}

output "instance2_status" {
  value = huaweicloud_compute_instance.instance[1].status
}

output "instance_priv_addr1" {
  value = huaweicloud_compute_instance.instance[0].access_ip_v4
}

output "instance_priv_addr2" {
  value = huaweicloud_compute_instance.instance[1].access_ip_v4
}