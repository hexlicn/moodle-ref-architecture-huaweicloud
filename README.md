# Hosting Moodle on HUAWEICLOUD

Reference Architecture for Deploying Moodle on Huawei Cloud 

## Table of Contents

- [Introduction](https://github.com/hexlicn/moodle-ref-architecture-huaweicloud#introduction)
- [How to Provision](https://github.com/hexlicn/moodle-ref-architecture-huaweicloud#how-to-provision)
- [Architecture](https://github.com/hexlicn/moodle-ref-architecture-huaweicloud#architecture)
- [Contacts](https://github.com/hexlicn/moodle-ref-architecture-huaweicloud#contacts)

## Introduction

In order to deploy open source Moodle learning platform on Huawei Cloud by simplifying the provision process, we define the well-designed architecture and suite of IaC (Infrastructure as Code) scripts for automation based on Huawei Cloud native Application Orchestration Service (AOS), HashiCorp packer and Terraform.

AOS template basically provides 2 YAML scripts for deploying Moodle on Huawei Cloud by cloud VM version and container version. We will adopt [Huawei Cloud Virtual Private Cloud  (VPC)](https://support.huaweicloud.com/intl/en-us/vpc/), [Huawei Cloud Container Engine (CCE)](https://support.huaweicloud.com/intl/en-us/cce/),  [Huawei Cloud Elastic Compute Server (ECS)](https://support.huaweicloud.com/intl/en-us/ecs/), [Auto Scaling](https://support.huaweicloud.com/intl/en-us/as/), [Huawei Cloud Elastic Load Balance (ELB)](https://support.huaweicloud.com/intl/en-us/elb/), [Huawei Cloud Relational Database Service (RDS for MySQL)](https://support.huaweicloud.com/intl/en-us/rds/), [Huawei Cloud Distributed Cache Service (DCS for Redis)](https://support.huaweicloud.com/intl/en-us/dcs/), [Huawei Cloud Scalable File Service (SFS Turbo)](https://support.huaweicloud.com/intl/en-us/sfs/), [Huawei Cloud Content Delivery Network (Optional)](http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html), [Huawei Cloud DNS (Optional)](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html) with [Huawei Cloud AOS](https://support.huaweicloud.com/intl/en-us/aos/). This typical architecture could suitable for many Moodle deployments, however the templates can be run individually and/or modified to deploy a subset of the architecture that fits your requirements.

## How to Provision

### Huawei Cloud AOS

Navigate to folder [aos-templates](https://github.com/hexlicn/moodle-ref-architecture-huaweicloud/tree/main/aos-templates) , download YAML scripts to your clients and launch from [here](https://console-intl.huaweicloud.com/aos/?region=af-south-1&locale=en-us#/app/dashboard) to proceed with creating template, then create stack based on that. 

### Packer / Terraform

Navigate to folder [tf-packer-scripts](https://github.com/hexlicn/moodle-ref-architecture-huaweicloud/tree/main/tf-packer-scripts), download them into your clients with packer / terraform plugin installed (see [Packer install doc](https://www.packer.io/docs/install) and [Terraform install doc](https://learn.hashicorp.com/tutorials/terraform/install-cli) for details), plan and apply from there. 

### Action Plan notes

- If you plan to use HTTPS, you must create and import your TLS certificate into web server (Nginx, Apache), within the VM or Docker containers, you can also off load the certificate by Huawei Cloud ELB.
- After launching AOS YAML template, you can create Auto Scaling Group (ASG) and it's rules/policies by Huawei Cloud console that according to your needs.
- After the stack deployment completes (AOS or Terraform, VM or Container), please navigate to the web site to complete the Moodle installation. 
- Configure Application caching and Session caching in Moodle Site Configuration as recommended.
- Any other configuration, like tuning your web server, PHP etc. please login to VM or exec to Docker container to change the parameter.
- VM deployment need a "golden image", you can download it from [here](https://temp-l00490846.obs.af-south-1.myhuaweicloud.com/img-moodle.qcow2) and [upload](https://support.huaweicloud.com/intl/en-us/usermanual-ims/ims_01_0210.html) to your Huawei Cloud account, conform as your [private image](https://support.huaweicloud.com/intl/en-us/usermanual-ims/ims_01_0211.html); or contact [me](lihexin1@huawei.com) to share with you a image, and then launching the AOS template. 

## Architecture

The following architecture blueprint is based on VM deployment and cloud database/cache, just for your reference to deploy a basic Moodle web site on Huawei Cloud. You may want to change to suite for your requirements.

![image](https://raw.githubusercontent.com/hexlicn/moodle-ref-architecture-huaweicloud/main/images/huaweicloud-refarch-moodle-architecture-vm.png)

The following architecture blueprint is based on container deployment and cloud database/cache,  just for your reference to deploy a basic Moodle web site on Huawei Cloud. You may want to change to suite for your requirements.

![image](https://raw.githubusercontent.com/hexlicn/moodle-ref-architecture-huaweicloud/main/images/huaweicloud-refarch-moodle-architecture-container.png)

## Contacts

Author: Harrison Li, Email @[me](lihexin1@huawei.com)

