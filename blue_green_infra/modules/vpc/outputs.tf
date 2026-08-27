output "vpc_id" {
  value       = aws_vpc.blue_green_vpc.id
  description = "The ID of the VPC"
}
output "public_subnet_1_id" {
  value       = aws_subnet.public_subnet_1.id
  description = "The ID of the public subnet 1"
}
output "public_subnet_2_id" {
  value       = aws_subnet.public_subnet_2.id
  description = "The ID of the public subnet 2"
}
output "private_subnet_1_id" {
  value       = aws_subnet.private_subnet_1.id
  description = "The ID of the private subnet 1"
}
output "private_subnet_2_id" {
  value       = aws_subnet.private_subnet_2.id
  description = "The ID of the private subnet 2"
}
output "private_subnet_3_id" {
  value       = aws_subnet.private_subnet_3.id
  description = "The ID of the private subnet 3"
}
output "private_subnet_4_id" {
  value       = aws_subnet.private_subnet_4.id
  description = "The ID of the private subnet 4"
}