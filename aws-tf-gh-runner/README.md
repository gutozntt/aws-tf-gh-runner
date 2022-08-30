## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_runner"></a> [runner](#module\_runner) | terraform-aws-modules/ec2-instance/aws | 4.1.2 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | AMI ID for your Runners. | `string` | n/a | yes |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | IAM Role for your Runners. | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 Instance Type for your Runners. | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | EC2 Key Pair Name for your Runners. | `string` | n/a | yes |
| <a name="input_label"></a> [label](#input\_label) | Github Labels for your Runners. | `string` | n/a | yes |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | Whether to enable monitoring for your Runners. | `bool` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region for your Runners. | `string` | n/a | yes |
| <a name="input_runner_architecture"></a> [runner\_architecture](#input\_runner\_architecture) | Architecture for your Runners. It should be one of the following: x64, ARM or ARM64 | `string` | n/a | yes |
| <a name="input_runner_name"></a> [runner\_name](#input\_runner\_name) | Name for your Runners. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for your Runners. | `string` | n/a | yes |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of Security Groups for your Runners. | `list(any)` | n/a | yes |

## Outputs

No outputs.
