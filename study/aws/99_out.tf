output "bat_ip" {
  value = aws_eip.bat_pip.public_ip
}

output "natgw_ip" {
  value = aws_eip.natgw_pip.public_ip
}

output "natgw_allocation_ip" {
    value = aws_nat_gateway.natgw.public_ip
}

output "bat_public_ip" {
  value = aws_instance.brkim_bat.public_ip
}

output "load_dns" {
  value = aws_lb.brkim_lb.dns_name
}