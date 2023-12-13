output "public_snet_id" {
  value = aws_subnet.public_snet.id
}

output "private_snet_id" {
  value = local.private_snet_count == 0 ? null : aws_subnet.private_snet[0].id
}

output "isolated_snet_id" {
  value = local.isolated_snet_count == 0 ? null : aws_subnet.isolated_snet[0].id
}