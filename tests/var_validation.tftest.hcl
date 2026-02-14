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

################################################################################
# Variable Validation - ネガティブパス (expect_failures)
################################################################################

run "validation_name_must_not_be_empty" {
  command = plan

  variables {
    name = ""
  }

  expect_failures = [
    var.name,
  ]
}

run "validation_invalid_vpc_cidr" {
  command = plan

  variables {
    vpc_cidr = "not-a-cidr"
  }

  expect_failures = [
    var.vpc_cidr,
  ]
}

run "validation_invalid_subnet_cidr" {
  command = plan

  variables {
    private_subnets = ["invalid"]
  }

  expect_failures = [
    var.private_subnets,
  ]
}

run "validation_natgw_requires_igw" {
  command = plan

  variables {
    create_internet_gateway = false
    create_nat_gateway      = true
    public_subnets          = []
  }

  expect_failures = [
    var.create_nat_gateway,
  ]
}
