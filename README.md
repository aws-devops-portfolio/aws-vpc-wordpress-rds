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
- Autoscaling Group - 
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

## Provisioned resources
- Git push triggering deployment in Github actions
![alt text](<images/git_push.png>)

- The AMI has been successfully created by packer job:
![alt text](<images/ami_creation.png>)

- Created AMI details:
![alt text](<images/ami_details.png>)

- AMI Id stored in Parameter Store
![alt text](<images/ami_in_parameter_store.png>)

- Successful provisioning of infrastructure in Github Actions:
![alt text](<images/infrastructure_provisioning.png>)

- Amazon S3 backend state
![alt text](<images/s3_backend_state.png>)

- EC2 instance launched successfully
![alt text](<images/ec2_instance_details.png>)

- VPC created
![alt text](<images/vpc_details.png>)

- Security Groups
![alt text](<images/security_groups.png>)

- Database created
![alt text](<images/rds_details.png>)

- Load Balancer
![alt text](<images/load_balancer.png>)

- Target Group with a healthy EC2 instance
![alt text](<images/target_group.png>)

- Autoscaling Group
![alt text](<images/autoscaling_group.png>)

## Deployed Wordpress application
DISCLAIMER: For this demo, the Load Balancer listener has been configured with protocol HTTP as there's currenly no public domain that has been configured. In future the listener will be configured to use HTTPS.  
Load Balancer endpoint:  wordpress-alb-772095463.us-east-1.elb.amazonaws.com

Wordpress landing page:
![alt text](<images/wordpress_landing.png>)

Wordpress setup page:
![alt text](<images/wordpress_setup.png>)

Wordpress login page:
![alt text](<images/wordpress_login.png>)

Wordpress home page:
![alt text](<images/wordpress_home.png>)

## Issues experienced
## 1. OIDC Role Assumption Failure (Github Actions - AWS)
   Issue
   Not authorized to perform sts:AssumeRoleWithWebIdentity

   Cause
   This can occur if:
   - The IAM role trust policy is missing or misconfigured.
   - The GitHub repository name or organization name in the trust policy is incorrect.
   - The token.actions.githubusercontent.com:sub condition does not include ref:refs/heads/main.

   Solution: 
   - Verify that the trust policy exists and allows sts:AssumeRoleWithWebIdentity.
   - Ensure GitHub repository name or organization name match exactly.  
   - Confirm that ref:refs/heads/main is included in the token.actions.githubusercontent.com:sub condition when      using OIDC 

## 2. 504 Bad Gateway response when accessing the application via Load balancer 
   Issue
   504 Bad Gateway error when accessing the application through the Application Load Balancer (ALB) endpoint

   Cause
   The Application Load Balancer was unable to forward traffic to the EC2 instances due to a missing egress (outbound) rule in the Load Balancer’s security group.

   Solution
   - Ensure that the security group attached to the Load Balancer has an egress rule allowing outbound traffic to the EC2 instance security group (or to the appropriate CIDR range)

## 3. Wordpress Database connection error
   Issue
   Error establishing a database connection

   Cause
   Incorrect database configuration values in wp-config.php, such as:
   - Wrong database host
   - Incorrect database name
   - Invalid database username or password 
   
   Solution
   - SSH into the EC2 instance
   - Verify the database configuration by running command:
      grep -E "DB_(NAME|USER|PASSWORD|HOST)" /var/www/html/wp-config.php
   - Confirm that the DB_NAME, DB_USER, DB_PASSWORD, and DB_HOST values match the RDS configuration 



