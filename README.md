VPC Wordpress RDS deployment

## OVERVIEW
This project provisions a secure AWS VPC, deploys a WordPress application on EC2, and connects it to an RDS MySQL database in private subnets.

## ARCHITECTURE
- VPC - with two public and two private subnets
- NAT Gateway - to allow internet access for EC2 instance inside private subnet
- Internet Gateway - to allow internet access for public subnets
- Security Groups - least priviledge network access
- RDS - MYSQL engine for Wordpress database  
- EC2 instance - hosting the Wordpress server in private subnet
- Load Balancer - distribute traffic across Availability Zones

## DEPLOYMENT
- Provisioned using Terraform
- Application is bootstrapped with userdata script

## DIAGRAM
![alt text](<images/architecture.png>)


## LEARNING OUTCOMES
- Designed a highly available, secure VPC  
- Automated EC2 + RDS provisioning  
- Configured WordPress with RDS backend
