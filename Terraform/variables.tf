variable "env" {
    description = "The environment in which the resources will exist; prod, dev, qa, staging, etc"
}

variable "project_tag" {
    description = "tag for identification of resources for usage/billing/etc"
} 

variable "vpc_cidr" {
    description = "CIDR block used for the VPC"
}

variable "sub_cidr" {
    description = "CIDR block used for the subnet"
}

variable "ami_id" {
    description = "ID for the desired AMI for server ec2 instance"
}

variable "instance_type" {
    description = "Instance type/size (ie t2.large) for server ec2 instance"
}

variable "az" {
    description = "Availability zone (format: us-east-1a, us-west-1b, etc"
}