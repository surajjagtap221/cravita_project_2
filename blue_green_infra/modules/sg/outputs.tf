output "blue_ec2_tg_sg_id" {
  value = aws_security_group.blue_ec2_tg_sg.id
}

output "green_ec2_tg_sg_id" {
  value = aws_security_group.green_ec2_tg_sg.id
}
