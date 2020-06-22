# terraform-aws-transfer-custom-idp
![](https://github.com/gotooooo/terraform-aws-transfer-custom-idp/workflows/lint/badge.svg)

Terraform module which creates [Custom Identity Provider](https://docs.aws.amazon.com/transfer/latest/userguide/authenticating-users.html) for AWS Transfer Family.

## Usage

```hcl
resource "aws_s3_bucket" "bucket" {
  bucket = "bucket_name"
}

resource "aws_iam_role" "apigw_logging" {
  name = "apigw-logging-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "apigateway.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "apigw_logging" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
  role       = aws_iam_role.apigw_logging.name
}

resource "aws_iam_role" "lambda_basic_execution" {
  name = "lambda-basic-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_basic_execution.name
}


module "idp" {
  source = "git::https://github.com/gotooooo/terraform-aws-transfer-custom-idp.git?ref=0.0.1"

  s3_bucket_arn                       = aws_s3_bucket.bucket.arn
  iam_role_apigw_logging_arn          = aws_iam_role.apigw_logging.arn
  iam_role_lambda_basic_execution_arn = aws_iam_role.lambda_basic_execution.arn
}
```

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
