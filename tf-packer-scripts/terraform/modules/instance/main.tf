#----ecs----
data "huaweicloud_availability_zones" "sa_az" {
    region = var.region
    state  = "available"
}

data "huaweicloud_compute_flavors" "moodle_flavor" {
  availability_zone = data.huaweicloud_availability_zones.sa_az.names[0]
  performance_type  = "normal"
  cpu_core_count    = 2
  memory_size       = 4
}

// data "huaweicloud_vpc" "vpc_moodle" {
//   name = var.vpc_id
// }

data "huaweicloud_vpc_subnet" "subnet_moodle_app" {
  id = var.network_id_app
}

data "huaweicloud_images_image" "moodle_image" {
  name        = "packer-image-moodle"
  visibility  = "private"
  most_recent = true
}

data "huaweicloud_networking_secgroup" "secgroup_moodle_app" {
  name = var.instance_security_group
}

resource "huaweicloud_compute_keypair" "moodle_keypair" {
  region     = var.region
  name       = "moodle-keypair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDS23sptwaFtayw5roRldmFdgagREGYL45D3c1GwNWlIFKwZ9igLn3KD8C7VwTwyj0Kc0Bf2g4MT3QU8kb9rerSTWds1Z0mMVOKPe1t0uP2erFKAlbrfspKpSsDrdCN3eX9im6qSkbt/lgOKzMdmecFvepTY8P0JPOTYWwhtwVGuW0LRTzTA9VbcO9q7Nkeof1k4J5c04VQ8vBlEJSEsmZbaD0PBSYi9F9W4X0n5shhscFyuIPYAIQnX7v7f1PR5tMjxH2qUMBq2dhTGAKZGsgEz1ebxLLMZgzDOTS409SHge2CGfRsfEq2I+FYg4Y+6HPtHpaubBrHlQ3ZIEonmY6N root@hadoop3server"
}

resource "huaweicloud_compute_instance" "instance" {
  name               = "instance_${count.index}"
  image_id           = data.huaweicloud_images_image.moodle_image.id
  flavor_id          = data.huaweicloud_compute_flavors.moodle_flavor.ids[0]
  key_pair           = huaweicloud_compute_keypair.moodle_keypair.name
  availability_zone  = data.huaweicloud_availability_zones.sa_az.names[0]
  security_group_ids = [data.huaweicloud_networking_secgroup.secgroup_moodle_app.id]

  network {
    uuid = data.huaweicloud_vpc_subnet.subnet_moodle_app.id
  }
  count = 2
}

#----asg----
resource "huaweicloud_as_configuration" "moodle_as_config" {
  scaling_configuration_name = "moodle_as_config"

  instance_config {
    flavor   = data.huaweicloud_compute_flavors.moodle_flavor.ids[0]
    image    = data.huaweicloud_images_image.moodle_image.id
    key_name = huaweicloud_compute_keypair.moodle_keypair.name
    disk {
      size        = 40
      volume_type = "SAS"
      disk_type   = "SYS"
    }
  }
}

resource "huaweicloud_as_group" "moodle_as_group" {
  scaling_group_name       = "moodle_as_group"
  scaling_configuration_id = huaweicloud_as_configuration.moodle_as_config.id
  desire_instance_number   = 2
  min_instance_number      = 0
  max_instance_number      = 10
  vpc_id                   = var.vpc_id
  delete_publicip          = true
  delete_instances         = "yes"

  networks {
    id = data.huaweicloud_vpc_subnet.subnet_moodle_app.id
  }
  security_groups {
    id = data.huaweicloud_networking_secgroup.secgroup_moodle_app.id
  }
  lbaas_listeners {
    pool_id       = var.elb_pool_id
    protocol_port = var.elb_listener_port
  }
}

resource "huaweicloud_ces_alarmrule" "scaling_up_rule" {
  alarm_name = "scaling_up_rule"

  metric {
    namespace   = "SYS.AS"
    metric_name = "cpu_util"
    dimensions {
      name  = "AutoScalingGroup"
      value = huaweicloud_as_group.moodle_as_group.id
    }
  }
  condition {
    period              = 300
    filter              = "average"
    comparison_operator = ">="
    value               = 80
    unit                = "%"
    count               = 1
  }
  alarm_actions {
    type              = "autoscaling"
    notification_list = []
  }
}

resource "huaweicloud_ces_alarmrule" "scaling_down_rule" {
  alarm_name = "scaling_down_rule"

  metric {
    namespace   = "SYS.AS"
    metric_name = "cpu_util"
    dimensions {
      name  = "AutoScalingGroup"
      value = huaweicloud_as_group.moodle_as_group.id
    }
  }
  condition {
    period              = 300
    filter              = "average"
    comparison_operator = "<="
    value               = 20
    unit                = "%"
    count               = 1
  }
  alarm_actions {
    type              = "autoscaling"
    notification_list = []
  }
}

resource "huaweicloud_as_policy" "scaling_up_policy" {
  scaling_policy_name = "scaling_up_policy"
  scaling_policy_type = "ALARM"
  scaling_group_id    = huaweicloud_as_group.moodle_as_group.id  
  alarm_id            = huaweicloud_ces_alarmrule.scaling_up_rule.id
  cool_down_time      = 300

  scaling_policy_action {
    operation       = "ADD"
    instance_number = 1
  }
}

resource "huaweicloud_as_policy" "scaling_down_policy" {
  scaling_policy_name = "scaling_down_policy"
  scaling_policy_type = "ALARM"
  scaling_group_id    = huaweicloud_as_group.moodle_as_group.id  
  alarm_id            = huaweicloud_ces_alarmrule.scaling_down_rule.id
  cool_down_time      = 300

  scaling_policy_action {
    operation       = "REMOVE"
    instance_number = 1
  }
}

#----sfs turbo----
resource "huaweicloud_sfs_turbo" "sfs-turbo-moodledata" {
  name              = "sfs-turbo-moodle-data"
  size              = 500
  share_proto       = "NFS"
  vpc_id            = var.vpc_id
  subnet_id         = data.huaweicloud_vpc_subnet.subnet_moodle_app.id
  security_group_id = data.huaweicloud_networking_secgroup.secgroup_moodle_app.id
  availability_zone = data.huaweicloud_availability_zones.sa_az.names[1]
}