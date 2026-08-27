output vpc_id {
  value = aws_vpc.blue_green_vpc.id
  description = "The ID of the VPC"
}