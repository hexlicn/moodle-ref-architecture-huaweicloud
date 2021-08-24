packer {
  required_plugins {
    huaweicloud = {
      version = ">= 0.4.0"
      source  = "github.com/huaweicloud/huaweicloud"
    }
  }
}

variable "access_key" {
  type = string
}
variable "secret_key" {
  type = string
}

variable "source_image_id" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "subent_id" {
  type = string
}

source "huaweicloud-ecs" "build-moodel-img" {
  region     = "af-south-1"
  access_key = var.access_key
  secret_key = var.secret_key
  flavor     = "s6.large.2"
  source_image       = var.source_image_id
  image_name         = "packer-image-moodle"
  vpc_id             = var.vpc_id
  subnets            = [var.subent_id]
  security_groups    = ["sg-moodle-app"]
  eip_bandwidth_size = 1
  eip_type           = "5_bgp"
  ssh_ip_version     = "4"
  ssh_username       = "root"
}

build {
  sources = ["source.huaweicloud-ecs.build-moodel-img"]

  provisioner "shell" {
    inline = [
      "echo \"start update Ubuntu to the lasted packages, sleep 20s first\"",
      "sleep 20",
      "echo \"run update package\"",
      "sudo apt -y update",
      "echo \"update package done\"",
      "sleep 10",
      "echo \"run install AMP\"",
      "sudo apt -y install apache2 mysql-client mysql-server php libapache2-mod-php git",
      "echo \"install AMP done\"",
      "sleep 10",
      "echo \"run install other software\"",
      "sudo apt -y install graphviz aspell ghostscript clamav php7.4-pspell php7.4-curl php7.4-gd php7.4-intl php7.4-mysql php7.4-xml php7.4-xmlrpc php7.4-ldap php7.4-zip php7.4-soap php7.4-mbstring",
      "echo \"enable install other software done\"",
      "sleep 10",
      "echo \"run start HTTP service\"",
      "sudo systemctl restart apache2; sudo systemctl enable apache2",
      "echo \"start HTTP service done\"",
      "sleep 10",
      "echo \"run download Moodle\"",
      "cd /opt",
      "sudo git clone git://git.moodle.org/moodle.git",
      "cd moodle",
      "sudo git branch -a",
      "sudo git branch --track MOODLE_39_STABLE origin/MOODLE_39_STABLE",
      "sudo git checkout MOODLE_39_STABLE",
      "sudo cp -R /opt/moodle /var/www/html/",
      "sudo chmod -R 0755 /var/www/html/moodle",
      "echo \"download Moodle done\""
    ]
  }
}