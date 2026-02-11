mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
    }
  }
}

# 共通デフォルト — 各runブロックでは差分のみ上書き
variables {
  name            = "my-app"
  vpc_cidr        = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

################################################################################
# VPC
################################################################################

run "vpc_defaults" {
  command = plan

  assert {
    condition     = aws_vpc.this.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR should match the specified value"
  }

  assert {
    condition     = aws_vpc.this.enable_dns_hostnames == true && aws_vpc.this.enable_dns_support == true
    error_message = "DNS hostnames and support should be enabled by default"
  }

  assert {
    condition     = aws_vpc.this.tags["Name"] == "my-app-vpc"
    error_message = "VPC Name tag should follow '{name}-vpc' convention"
  }
}

run "vpc_dns_can_be_disabled" {
  command = plan

  variables {
    enable_dns_hostnames = false
    enable_dns_support   = false
  }

  assert {
    condition     = aws_vpc.this.enable_dns_hostnames == false && aws_vpc.this.enable_dns_support == false
    error_message = "DNS settings should be disableable"
  }
}

################################################################################
# Subnets - 正常系
################################################################################

run "subnets_three_az" {
  command = plan

  assert {
    condition     = length(aws_subnet.private) == 3 && length(aws_subnet.public) == 3
    error_message = "Subnet count should match the number of CIDRs provided"
  }

  assert {
    condition     = toset([for s in aws_subnet.private : s.availability_zone]) == toset(["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"])
    error_message = "Private subnets should be distributed across all AZs"
  }

  assert {
    condition     = toset([for s in aws_subnet.public : s.availability_zone]) == toset(["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"])
    error_message = "Public subnets should be distributed across all AZs"
  }

  assert {
    condition     = aws_subnet.private[0].tags["Name"] == "my-app-private-0"
    error_message = "Private subnet Name tag should follow '{name}-private-{index}' convention"
  }

  assert {
    condition     = aws_subnet.public[0].tags["Name"] == "my-app-public-0"
    error_message = "Public subnet Name tag should follow '{name}-public-{index}' convention"
  }
}

run "subnets_empty" {
  command = plan

  variables {
    private_subnets = []
    public_subnets  = []
  }

  assert {
    condition     = length(aws_subnet.private) == 0 && length(aws_subnet.public) == 0
    error_message = "No subnets should be created when lists are empty"
  }
}

################################################################################
# Variable Validation - ネガティブパス (expect_failures)
################################################################################

run "invalid_vpc_cidr_should_fail" {
  command = plan

  variables {
    vpc_cidr = "not-a-cidr"
  }

  expect_failures = [
    var.vpc_cidr,
  ]
}

run "invalid_subnet_cidr_should_fail" {
  command = plan

  variables {
    private_subnets = ["invalid"]
  }

  expect_failures = [
    var.private_subnets,
  ]
}
