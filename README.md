# terraform-aws-network

VPC・サブネット・Internet Gateway・NAT Gateway を作成する Terraform モジュール。

## Usage

### プライベートサブネットのみ

```hcl
module "network" {
  source = "git::https://github.com/hiro1202/terraform-aws-network.git"

  name            = "my-app"
  vpc_cidr        = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
}
```

### パブリック・プライベート構成（NAT Gateway あり）

```hcl
module "network" {
  source = "git::https://github.com/hiro1202/terraform-aws-network.git"

  name            = "my-app"
  vpc_cidr        = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  create_internet_gateway = true
  create_nat_gateway      = true
}
```

## Development

| Command          | Description                              |
|------------------|------------------------------------------|
| `make init`      | `terraform init -backend=false` を実行   |
| `make fmt`       | `terraform fmt -recursive -diff` を実行             |
| `make validate`  | `make init` 後に `terraform validate` を実行                     |
| `make test`      | `make init` 後に `terraform test` を実行                  |
| `make checkov`   | Checkov でセキュリティスキャンを実行     |
| `make ci`        | すべてのチェックを実行（fmt / validate / test / checkov） |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.30.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_internet_gateway"></a> [create\_internet\_gateway](#input\_create\_internet\_gateway) | Internet Gatewayを作成する場合はtrue | `bool` | `false` | no |
| <a name="input_create_nat_gateway"></a> [create\_nat\_gateway](#input\_create\_nat\_gateway) | NAT Gatewayを作成する場合はtrue | `bool` | `false` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | VPCでDNSホスト名を有効にする場合はtrue | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | VPCでDNSサポートを有効にする場合はtrue | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | すべてのリソースの識別子として使用される名前 | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | プライベートサブネットのCIDRブロックリスト | `list(string)` | `[]` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | パブリックサブネットのCIDRブロックリスト | `list(string)` | `[]` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPCのCIDRブロック | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#output\_private\_subnet\_cidrs) | プライベートサブネットのCIDRブロックリスト |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | プライベートサブネットのIDリスト |
| <a name="output_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#output\_public\_subnet\_cidrs) | パブリックサブネットのCIDRブロックリスト |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | パブリックサブネットのIDリスト |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | VPCのCIDRブロック |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPCのID |
<!-- END_TF_DOCS -->

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
