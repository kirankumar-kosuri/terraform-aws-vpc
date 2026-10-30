# Terraform Aws Vpc

This module creates the following resources

* VPC
* Internet Gateway (IGW)
* 2 public subnets in us-east-1a and us-east-1b Availability Zones
* 2 private subnets in us-east-1a and us-east-1b Availability Zones
* 2 database subnets in us-east-1a and us-east-1b Availability Zones
* Public route table
* Private route table
* Database route table
* Elastic IP (EIP) for NAT Gateway
* NAT Gateway in public subnet 1a
* IGW route added to the public route table
* NAT Gateway routes added to the private and database route tables
* Route table associations with subnets
* VPC peering connection between the created VPC and the default VPC
* Route from the public route table to the default VPC
* Route from the default VPC's main route table to the created VPC

# Inputs
* vpc_cidr - (Required). User must supply the CIDR for VPC.
* project_name - (Required). User must supply the project name.