variable "OS_Name" {
  type    = string
  default = "AmazonLinux"
}

variable "OS_Version" {
  type    = string
  default = "2"
}

variable "name" {
  type    = string
  default = "amzn2-example"
}

variable "instance_type" {
  type        = string
  description = "AWS instance type"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "source_ami_name" {
  description = "The base AMI name to filter for"
  type        = string
  default     = "amzn2-ami-hvm"
}

variable "subnet_id" {
  type        = string
  description = "The subnet ID to launch the instance in"
  default     = ""
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for EC2 instance"
  default     = ""
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to launch the instance in"
  default     = ""
}

variable "ami_users" {
  type        = list(string)
  description = "Users allowed to launch this AMI"
}
