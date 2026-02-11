variable "name" {
  description = "すべてのリソースの識別子として使用される名前"
  type        = string
  default     = ""
}

################################################################################
# VPC
################################################################################
variable "vpc_cidr" {
  description = "VPCのCIDRブロック"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidrは有効なCIDR表記で指定してください（例: 10.0.0.0/16）"
  }
}

variable "enable_dns_hostnames" {
  description = "VPCでDNSホスト名を有効にする場合はtrue"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "VPCでDNSサポートを有効にする場合はtrue"
  type        = bool
  default     = true
}

################################################################################
# Private Subnets
################################################################################
variable "private_subnets" {
  description = "プライベートサブネットのCIDRブロックリスト"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.private_subnets : can(cidrhost(cidr, 0))])
    error_message = "private_subnetsの各要素は有効なCIDR表記で指定してください"
  }
}

################################################################################
# Publiс Subnets
################################################################################
variable "public_subnets" {
  description = "パブリックサブネットのCIDRブロックリスト"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.public_subnets : can(cidrhost(cidr, 0))])
    error_message = "public_subnetsの各要素は有効なCIDR表記で指定してください"
  }
}
