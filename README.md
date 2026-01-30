VPC Wordpress RDS deployment

## OVERVIEW
This project provisions a secure AWS VPC, deploys a WordPress application on EC2, and connects it to an RDS MySQL database in private subnets.

## ARCHITECTURE
- Terraform - infrasture as code
- Packer - creation of custom AMI built with 
- VPC - with two public and two private subnets
- NAT Gateway - to allow internet access for EC2 instance inside private subnet
- Internet Gateway - to allow internet access for public subnets
- Security Groups - least priviledge network access
- RDS - MYSQL engine for Wordpress database 
- Secrets Manager - storing RDS generated credentials 
- IAM - permissions
- EC2 instance - hosting the Wordpress server in private subnet
- Load Balancer - distribute traffic across Availability Zones
- S3 - manage Terraform backend state
- SSM - store the created AMI id 

## DEPLOYMENT
- Provisioned using Terraform
- Application is bootstrapped with userdata script

## DIAGRAM
![alt text](<images/architecture.png>)


## LEARNING OUTCOMES
- Designed a highly available, secure VPC  
- Automated EC2 + RDS provisioning  
- Configured WordPress with RDS backend
- Created a customized machine image using Packer
- Integrated AWS OIDC Authentication with Github actions

## Challenges experienced
1. Issue: Could not assume role with OIDC: Not authorized to perform sts:AssumeRoleWithWebIdentity
   Solution: Diagnosed and fixed a GitHub Actions → AWS OIDC authentication failure by inspecting JWT claims and correcting IAM trust policy conditions.
  
