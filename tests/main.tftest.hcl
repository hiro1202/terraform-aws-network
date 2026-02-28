test {
  parallel = true
}

mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
    }
  }
}

# デフォルト変数値 — 各runブロックでは差分のみ上書き
variables {
  name = "my-app"
}

################################################################################
# VPC
################################################################################

run "vpc_basic_settings" {
  command = apply

  variables {
    vpc_cidr = "192.168.0.0/16"
  }

  assert {
    condition     = aws_vpc.this.cidr_block == "192.168.0.0/16"
    error_message = "VPCのCIDRは指定した値（192.168.0.0/16）と一致する必要があります"
  }

  assert {
    condition     = aws_vpc.this.enable_dns_hostnames == true && aws_vpc.this.enable_dns_support == true
    error_message = "DNSホスト名とDNSサポートはデフォルトで有効である必要があります（true）"
  }

  assert {
    condition     = aws_vpc.this.tags["Name"] == "my-app-vpc"
    error_message = "VPCのNameタグは「{name}-vpc」の形式である必要があります"
  }
}

run "vpc_disable_dns" {
  command = apply

  variables {
    enable_dns_hostnames = false
    enable_dns_support   = false
  }

  assert {
    condition     = aws_vpc.this.enable_dns_hostnames == false && aws_vpc.this.enable_dns_support == false
    error_message = "DNS設定は無効化できる必要があります"
  }
}

run "default_sg_has_no_rules" {
  command = apply

  assert {
    condition     = length(aws_default_security_group.this.ingress) == 0
    error_message = "デフォルトSGにingressルールが残っています"
  }

  assert {
    condition     = length(aws_default_security_group.this.egress) == 0
    error_message = "デフォルトSGにegressルールが残っています"
  }

  assert {
    condition     = aws_default_security_group.this.tags["Name"] == "my-app-default-sg"
    error_message = "デフォルトSGのNameタグは「{name}-default-sg」の形式である必要があります"
  }
}

################################################################################
# Subnets
################################################################################

run "subnets_multiple_azs" {
  command = apply

  variables {
    vpc_cidr                = "192.168.0.0/16"
    create_internet_gateway = true
    private_subnets         = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
    public_subnets          = ["192.168.101.0/24", "192.168.102.0/24", "192.168.103.0/24"]
  }

  assert {
    condition     = length(aws_subnet.private) == 3 && length(aws_subnet.public) == 3
    error_message = "各サブネットは3つずつ作成される必要があります"
  }

  assert {
    condition     = toset([for s in aws_subnet.private : s.availability_zone]) == toset(data.aws_availability_zones.available.names)
    error_message = "プライベートサブネットは3AZに分散配置される必要があります"
  }

  assert {
    condition     = toset([for s in aws_subnet.public : s.availability_zone]) == toset(data.aws_availability_zones.available.names)
    error_message = "パブリックサブネットは3AZに分散配置される必要があります"
  }

  assert {
    condition     = aws_subnet.private[0].tags["Name"] == "my-app-private-0"
    error_message = "プライベートサブネットのNameタグは「{name}-private-{index}」の形式である必要があります"
  }

  assert {
    condition     = aws_subnet.public[0].tags["Name"] == "my-app-public-0"
    error_message = "パブリックサブネットのNameタグは「{name}-public-{index}」の形式である必要があります"
  }
}

run "subnets_none_when_lists_empty" {
  command = apply

  variables {
    private_subnets = []
    public_subnets  = []
  }

  assert {
    condition     = length(aws_subnet.private) == 0 && length(aws_subnet.public) == 0
    error_message = "リストが空の場合、サブネットは作成されない必要があります"
  }
}

################################################################################
# Internet Gateway
################################################################################

run "igw_not_created_when_disabled" {
  command = apply

  variables {
    create_internet_gateway = false
  }

  assert {
    condition     = length(aws_internet_gateway.this) == 0
    error_message = "create_internet_gateway=falseの場合、IGWは作成されない必要があります"
  }

  assert {
    condition     = length(aws_route.public_internet) == 0
    error_message = "create_internet_gateway=falseの場合、パブリックルートは作成されない必要があります"
  }
}

run "igw_created_when_enabled" {
  command = apply

  variables {
    create_internet_gateway = true
    vpc_cidr                = "192.168.0.0/16"
    public_subnets          = ["192.168.101.0/24"]
  }

  assert {
    condition     = length(aws_internet_gateway.this) == 1
    error_message = "create_internet_gateway=trueの場合、IGWが1つ作成される必要があります"
  }

  assert {
    condition     = aws_internet_gateway.this[0].tags["Name"] == "my-app-igw"
    error_message = "IGWのNameタグは「{name}-igw」の形式である必要があります"
  }

  assert {
    condition     = length(aws_route.public_internet) == 1
    error_message = "create_internet_gateway=trueかつpublic_subnetsが空でない場合、パブリックルート（0.0.0.0/0）が作成される必要があります"
  }
}

################################################################################
# NAT Gateway
################################################################################

run "natgw_not_created_when_disabled" {
  command = apply

  assert {
    condition     = length(aws_nat_gateway.this) == 0
    error_message = "create_nat_gateway=falseの場合、NAT Gatewayは作成されない必要があります"
  }

  assert {
    condition     = length(aws_eip.nat) == 0
    error_message = "create_nat_gateway=falseの場合、EIPは作成されない必要があります"
  }

  assert {
    condition     = length(aws_route.private_nat) == 0
    error_message = "create_nat_gateway=falseの場合、プライベートNATルートは作成されない必要があります"
  }
}

run "natgw_created_when_enabled" {
  command = apply

  variables {
    create_nat_gateway      = true
    create_internet_gateway = true
    vpc_cidr                = "192.168.0.0/16"
    public_subnets          = ["192.168.101.0/24", "192.168.102.0/24", "192.168.103.0/24"]
    private_subnets         = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 3
    error_message = "create_nat_gateway=trueの場合、パブリックサブネットごとにNAT Gatewayが作成される必要があります"
  }

  assert {
    condition     = aws_nat_gateway.this[0].tags["Name"] == "my-app-nat-0"
    error_message = "NAT GatewayのNameタグは「{name}-nat-{index}」の形式である必要があります"
  }

  assert {
    condition     = length(aws_eip.nat) == 3
    error_message = "create_nat_gateway=trueの場合、パブリックサブネットごとにEIPが作成される必要があります"
  }

  assert {
    condition     = aws_eip.nat[0].tags["Name"] == "my-app-nat-eip-0"
    error_message = "EIPのNameタグは「{name}-nat-eip-{index}」の形式である必要があります"
  }

  assert {
    condition     = length(aws_route.private_nat) == 3
    error_message = "create_nat_gateway=trueの場合、プライベートサブネットごとにNATルートが作成される必要があります"
  }
}
