# terraform-aws-transfer-custom-idp
![](https://github.com/gotooooo/terraform-aws-transfer-custom-idp/workflows/lint/badge.svg?branch=develop)

Terraform module which creates [Custom Identity Provider](https://docs.aws.amazon.com/transfer/latest/userguide/authenticating-users.html) for AWS Transfer Family.

## Examples

- [Simple custom idp example](https://github.com/gotooooo/terraform-aws-transfer-custom-idp/tree/develop/examples/simple-custom-idp) shows the minimal example.

## Inputs

| Name | Description | Type | Default | Required |
| :-- | :-- | :-- | :-- | :-: |
| s3_bucket_arn | The arn of the S3 bucket used for the Transfer Server | `string` |  | yes |
| iam_role_apigw_logging_arn | The arn of the IAM Role used by the API Gateway for logging | `string` |  | yes |
| iam_role_lambda_basic_execution_arn | The arn of the IAM Role used by the Lambda for executing lambda functions | `string` |  | yes |
| name_prefix | String to use as a prefix for the object names | `string` | `""` | no |
| user_name | userName in lambda function | `string` | `"myuser"` | no |
| user_home_directory | userHomeDirectory in lambda function | `string` | `"/"` | no |
| user_password | userPassword in lambda function | `string` | `"MySuperSecretPassword"` | no |
| user_public_key_1 | userPublicKey1 in lambda function | `string` | `"ssh-rsa myrsapubkey"` | no |
| lambda_runtime | lambda runtime |  `string`  | `"nodejs12.x"` | no |
| lambda_get_user_config_function_source_dir | The source dir of the lambda function |  `string`  | `"use_default_function"` | no |
| lambda_get_user_config_function_output_path | The output path of the lambda function |  `string`  | `"use_default_function"` | no |

## Outputs

| Name | Description |
| :-- | :-- |
| apigw_deployment_invoke_url | The invoke url used by IdP of Transfer Server |

## License

MIT Licensed. See LICENSE for full details.