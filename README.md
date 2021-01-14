# Sentry Self Hosted Instance on EC2 using Terraform

It will provision a Sentry self-hosted setup on AWS EC2 Instance. It will perform the below tasks -
- Create a Private key and file
- Create a Key Pair
- Create Security groups (One for EC2 Instance and another for Application LB)
- Upload Self Signed Certificate to IAM 
- Create Application Load Balancer using the Self Signed Certificate
- Create Listener for Application Load  Balancer
- Create Target Group
- Perform Target Group Attachment
- Create AWS EC2 instance with user data automating the sentry install on this instance to the point of hitting the sentry login screen using the Application LB DNS Name

### Requirements
- Terraform version >= v0.14.4
- AWS Provider >= v3.0
- Default VPC 
- Default Public Subnet
- Self signed certificate in pem format with file names private.pem and public.pem present in the same folder as terraform and required '.tf' files

### Assumptions
- AWS Account is provisioned
- AWS CLI configured
- Terraform is installed

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| instance_type | EC2 Instance Type | string | `t2.medium` | yes |
| ami | AMI ID | string | `xxxxx` | yes |
| region | Region name | string | `xxxxx` | yes |
| vpc_id | Default VPC ID | string | `xxxxx` | yes |
| subnet | Subnet ID 1 | string | `xxxxx` | yes |
| subnet | Subnet ID 2 | string | `xxxxx` | yes |

### Outputs

| Name | Description | 
|------|-------------|
| EC2InstancePublicIP | Public IP of the EC2 Instance |
| SentryLoginURL | DNS name of the Application Load Balancer |

### Improvement Scope

- Creating web user for Sentry Login
- Use AutoScaling Group for spawning the instance to achieve resiliancy