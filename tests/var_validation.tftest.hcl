# Variable Validation 

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

variables {
  name = "test"
}


run "validation_name_must_not_be_empty" {
  command = plan

  variables {
    name = ""
  }

  expect_failures = [
    var.name,
  ]
}

################################################################################
# VPC
################################################################################

run "validation_invalid_vpc_cidr" {
  command = plan

  variables {
    vpc_cidr = "not-a-cidr"
  }

  expect_failures = [
    var.vpc_cidr,
  ]
}

################################################################################
# Private Subnets
################################################################################

run "validation_invalid_private_subnet_cidr" {
  command = plan

  variables {
    private_subnets = ["invalid"]
  }

  expect_failures = [
    var.private_subnets,
  ]
}

################################################################################
# Publiс Subnets
################################################################################

run "validation_invalid_public_subnet_cidr" {
  command = plan

  variables {
    create_internet_gateway = true
    public_subnets          = ["invalid"]
  }

  expect_failures = [
    var.public_subnets,
  ]
}

run "validation_public_subnet_requires_igw" {
  command = plan

  variables {
    create_internet_gateway = false
    public_subnets          = ["192.168.101.0/24"]
  }

  expect_failures = [
    var.public_subnets,
  ]
}

################################################################################
# NAT Gateway
################################################################################

run "validation_natgw_requires_igw" {
  command = plan

  variables {
    create_nat_gateway      = true
    create_internet_gateway = false
    public_subnets          = []
  }

  expect_failures = [
    var.create_nat_gateway,
  ]
}
