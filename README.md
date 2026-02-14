# terraform-aws-network

AWS のネットワークリソースを作成する Terraform モジュール。

## 変数

- `create_internet_gateway` (bool, default: `false`)
パブリックサブネットを作成する場合は `true` が必須。
- `create_nat_gateway` (bool, default: `false`)
NAT Gatewayを作成する場合は `create_internet_gateway = true` かつ `public_subnets` と `private_subnets` に1つ以上指定が必要。
- `nat_gateway_subnet_index` (number, default: `0`)
NAT Gatewayを配置する `public_subnets` のインデックス。

## テスト

```bash
terraform test
```

## 要件

- Terraform >= 1.0
- AWS Provider >= 6.31.0
