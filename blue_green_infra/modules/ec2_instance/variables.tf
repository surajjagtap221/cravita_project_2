variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "blue_ec2_sg_id" {
  description = "The ID of the security group for the blue EC2 instance"
  type        = string
}
variable "green_ec2_sg_id" {
  description = "The ID of the security group for the green EC2 instance"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}
variable "public_subnet_1_id" {
  description = "The ID of the public subnet 1"
  type        = string
}
variable "public_subnet_2_id" {
  description = "The ID of the public subnet 2"
  type        = string
}
variable "private_subnet_1_id" {
  description = "The ID of the private subnet 1"
  type        = string
}
variable "private_subnet_2_id" {
  description = "The ID of the private subnet 2"
  type        = string
}
variable "private_subnet_3_id" {
  description = "The ID of the private subnet 3"
  type        = string
}
variable "private_subnet_4_id" {
  description = "The ID of the private subnet 4"
  type        = string
}

variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}
variable "instance_type" {
  description = "The type of instance to use for the EC2 instance"
  type        = string
  default     = "t3.micro"
}
variable "key_name" {
  description = "The name of the key pair to use for the EC2 instance"
  type        = string
  default     = "cravita-key"
}