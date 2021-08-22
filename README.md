# Hosting Moodle on HUAWEI CLOUD

Reference Architecture for Deploying Moodle on Huawei Cloud 

## Table of Contents

- [Introduction](https://github.com/hexlicn/moodle-ref-architecture-huaweicloud#introduction)
- [How to Provision](https://github.com/hexlicn/moodle-ref-architecture-huaweicloud#how-to-provision)
- [Architecture](https://github.com/hexlicn/moodle-ref-architecture-huaweicloud#architecture)
- [AOS Orchestration](https://github.com/hexlicn/moodle-ref-architecture-huaweicloud#aos-orchestration)
- [Contacts](https://github.com/hexlicn/moodle-ref-architecture-huaweicloud#contacts)

## Introduction

In order to deploy open source Moodle learning platform on Huawei Cloud by simplifying the provision process, we define the well-designed architecture and suite of IaC (Infrastructure as Code) scripts for automation based on Huawei Cloud native Application Orchestration Service (AOS), Packer and Terraform.

AOS template basically provides 2 YAML scripts for deploying Moodle on Huawei Cloud by cloud VM version and container version. We will adopt [Huawei Cloud Virtual Private Cloud  (VPC)](https://support.huaweicloud.com/intl/en-us/vpc/), [Huawei Cloud Container Engine (CCE)](https://support.huaweicloud.com/intl/en-us/cce/),  [Huawei Cloud Elastic Compute Server (ECS)](https://support.huaweicloud.com/intl/en-us/ecs/), [Auto Scaling](https://support.huaweicloud.com/intl/en-us/as/), [Huawei Cloud Elastic Load Balance (ELB)](https://support.huaweicloud.com/intl/en-us/elb/), [Huawei Cloud Relational Database Service (RDS for MySQL)](https://support.huaweicloud.com/intl/en-us/rds/), [Huawei Cloud Distributed Cache Service (DCS for Redis)](https://support.huaweicloud.com/intl/en-us/dcs/), [Huawei Cloud Scalable File Service (SFS Turbo)](https://support.huaweicloud.com/intl/en-us/sfs/), [Huawei Cloud Content Delivery Network (Optional)](http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html), [Huawei Cloud DNS (Optional)](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html) with [Huawei Cloud AOS](https://support.huaweicloud.com/intl/en-us/aos/). This typical architecture could suitable for many Moodle deployments, however the templates can run individually and/or modified to deploy a subset of the architecture that fits your requirements.

## How to Provision

### Huawei Cloud AOS

Navigate to folder [aos-templates](https://github.com/hexlicn/moodle-ref-architecture-huaweicloud/tree/main/aos-templates) , download YAML scripts to your clients (laptop) and launch from [here](https://console-intl.huaweicloud.com/aos/?region=af-south-1&locale=en-us#/app/dashboard) to proceed with creating template, then create stack based on that. 

### Packer / Terraform

Navigate to folder [tf-packer-scripts](https://github.com/hexlicn/moodle-ref-architecture-huaweicloud/tree/main/tf-packer-scripts), download them into your clients (laptop) with packer / terraform plugin installed (see [Packer install doc](https://www.packer.io/docs/install) and [Terraform install doc](https://learn.hashicorp.com/tutorials/terraform/install-cli) for details), plan and apply from there. 

### Action Plan notes

- If you plan to use HTTPS, you must create and import your TLS certificate into web server (Nginx, Apache), within the VM or Docker containers, you can also "terminate" the certificate by Huawei Cloud ELB.
- After launching AOS YAML template, you can create Auto Scaling Group (ASG) and it's rules/policies by Huawei Cloud console that according to your needs; SFS Turbo is not supported on AOS now, so you need to provision the service instance and mount to Huawei Cloud computing instances; Again, it's highly recommended to create separate MySQL database instance for Moodle and assigned MySQL by any type of MySQL clients or Huawei Cloud Database Admin Service [(DAS)](https://support.huaweicloud.com/intl/en-us/qs-das/das_02_0003.html) for free as "Cloud DBA".
- After the stack deployment completes (AOS or Terraform, VM or Container), please navigate to the web site to complete the Moodle installation. 
- Configure Application caching and Session caching in Moodle Site Configuration to Huawei Cloud [DCS-Redis](https://support.huaweicloud.com/intl/en-us/qs-dcs/index.html) as recommended.
- Any other configuration, like tuning your web server, PHP etc. please login to VM or exec to Docker container to change the parameter.
- VM deployment need a "golden image", you can download it from [here](https://temp-l00490846.obs.af-south-1.myhuaweicloud.com/img-moodle.qcow2) and [upload](https://support.huaweicloud.com/intl/en-us/usermanual-ims/ims_01_0210.html) to your Huawei Cloud account, conform as your [private image](https://support.huaweicloud.com/intl/en-us/usermanual-ims/ims_01_0211.html); or contact [me](https://github.com/hexlicn/moodle-ref-architecture-huaweicloud/blob/main/README.md#contacts) to share with you a image, and then launching the AOS template. 
- When trial out with AOS YAML automation process, please remember to create KeyPair first for ECS login. Also create EIP and bind to the correct node that hosting Moodle app container.
- There's a potential bug when deleting AOS stack, please do check all the deployments, services, PVC, especially check configMap and secrets to see if they're purged already, if not, please delete them manually.

## Architecture

The following architecture blueprint is based on VM deployment and cloud database/cache, just for your reference to deploy a basic Moodle web site on Huawei Cloud. You may want to change to match your requirements.

![image](https://raw.githubusercontent.com/hexlicn/moodle-ref-architecture-huaweicloud/main/images/huaweicloud-refarch-moodle-architecture-vm.png)

The following architecture blueprint is based on container deployment and cloud database/cache,  just for your reference to deploy a basic Moodle web site on Huawei Cloud. You may want to change to match your requirements.

![image](https://raw.githubusercontent.com/hexlicn/moodle-ref-architecture-huaweicloud/main/images/huaweicloud-refarch-moodle-architecture-container.png)

## AOS Orchestration

The following snapshot shows the AOS YAML automation script orchestration topo drafted by Huawei Cloud AOS designer, mapping to VM-based architecture above.

![image](https://raw.githubusercontent.com/hexlicn/moodle-ref-architecture-huaweicloud/main/images/huaweicloud-refarch-moodle-architecture-vm-aos.png)

The following snapshot shows the AOS YAML automation script orchestration topo drafted by Huawei Cloud AOS designer, mapping to container-based architecture above.

![image](https://raw.githubusercontent.com/hexlicn/moodle-ref-architecture-huaweicloud/main/images/huaweicloud-refarch-moodle-architecture-container-aos.png)

## Contacts

Author: Harrison Li, Email [lihexin1@huawei.com](lihexin1@huawei.com)

