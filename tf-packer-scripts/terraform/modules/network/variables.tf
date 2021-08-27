variable "vpc_name" {
}

variable "base_cidr_block" {
}

variable "subnet_name_app" {
}

variable "subnet_cidr_app" {
  default = "172.16.0.0/24"
}

variable "subnet_gateway_ip_app" {
  default = "172.16.0.1"
}

variable "subnet_name_db" {
}

variable "subnet_cidr_db" {
  default = "172.16.1.0/24"
}

variable "subnet_gateway_ip_db" {
  default = "172.16.1.1"
}

variable "primary_dns" {
  default = "100.125.1.250"
}

variable "secgroup_name_app" {
}

variable "secgroup_name_db" {
}

variable "loadbalancer_name" {
  default = "elb-moodle"
}

variable "instance_addr1" {
}

variable "instance_addr2" {
}

variable "sgsapp" {
  default = [{
    name = "sg-moodle-app",
    rules = [{
      direction      = "ingress",
      ethertype      = "IPv4",
      protocol       = "tcp",
      port_range_min = "22",
      port_range_max = "22",
      remote_ip_cidr = "0.0.0.0/0"
      },
      {
        direction      = "ingress",
        ethertype      = "IPv4",
        protocol       = "tcp",
        port_range_min = "80",
        port_range_max = "80",
        remote_ip_cidr = "0.0.0.0/0"
      },
      {
        direction      = "ingress",
        ethertype      = "IPv4",
        protocol       = "tcp",
        port_range_min = "443",
        port_range_max = "443",
        remote_ip_cidr = "0.0.0.0/0"
      },
    ],
    },
  ]
}

variable "sgsdb" {
  default = [{
    name = "sg-moodle-db",
    rules = [{
      direction      = "ingress",
      ethertype      = "IPv4",
      protocol       = "tcp",
      port_range_min = "3306",
      port_range_max = "3306",
      remote_ip_cidr = "172.16.0.0/24"
      },
      {
        direction      = "ingress",
        ethertype      = "IPv4",
        protocol       = "tcp",
        port_range_min = "6379",
        port_range_max = "6379",
        remote_ip_cidr = "172.16.0.0/24"
      },
    ],
    },
  ]
}