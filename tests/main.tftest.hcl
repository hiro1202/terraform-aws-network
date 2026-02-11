mock_provider "aws" {}

run "default_vpc" {
  command = plan

  assert {
    condition     = output.vpc_cidr_block == "10.0.0.0/16"
    error_message = "Default VPC CIDR should be 10.0.0.0/16"
  }

  assert {
    condition     = length(output.private_subnet_ids) == 0
    error_message = "No private subnets should be created by default"
  }

  assert {
    condition     = length(output.public_subnet_ids) == 0
    error_message = "No public subnets should be created by default"
  }
}

run "with_subnets" {
  command = plan

  variables {
    vpc_cidr        = "172.16.0.0/16"
    private_subnets = ["172.16.1.0/24", "172.16.2.0/24"]
    public_subnets  = ["172.16.101.0/24"]
  }

  assert {
    condition     = output.vpc_cidr_block == "172.16.0.0/16"
    error_message = "VPC CIDR should match input"
  }

  assert {
    condition     = length(output.private_subnet_ids) == 2
    error_message = "Should create 2 private subnets"
  }

  assert {
    condition     = length(output.public_subnet_ids) == 1
    error_message = "Should create 1 public subnet"
  }

  assert {
    condition     = tolist(output.private_subnet_cidrs) == tolist(["172.16.1.0/24", "172.16.2.0/24"])
    error_message = "Private subnet CIDRs should match input"
  }

  assert {
    condition     = tolist(output.public_subnet_cidrs) == tolist(["172.16.101.0/24"])
    error_message = "Public subnet CIDRs should match input"
  }
}
