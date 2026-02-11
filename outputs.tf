output "vpc_id" {
  description = "VPCのID"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "VPCのCIDRブロック"
  value       = aws_vpc.this.cidr_block
}

output "private_subnet_ids" {
  description = "プライベートサブネットのIDリスト"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "プライベートサブネットのCIDRブロックリスト"
  value       = aws_subnet.private[*].cidr_block
}

output "public_subnet_ids" {
  description = "パブリックサブネットのIDリスト"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "パブリックサブネットのCIDRブロックリスト"
  value       = aws_subnet.public[*].cidr_block
}
