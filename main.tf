locals {
  source_dir  = var.lambda_get_user_config_function_source_dir == "use_default_function" ? "${path.module}/get_user_config" : var.lambda_get_user_config_function_source_dir
  output_path = var.lambda_get_user_config_function_output_path == "use_default_function" ? "${path.module}/get_user_config.zip" : var.lambda_get_user_config_function_output_path
}

# REST API
resource "aws_api_gateway_rest_api" "custom_identity_provider_rest_api" {
  name        = "${var.name_prefix}custom-identity-provider-rest-api"
  description = "API used for GetUserConfig requests"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Account
resource "aws_api_gateway_account" "custom_identity_provider_logging_account" {
  cloudwatch_role_arn = var.iam_role_apigw_logging_arn

  depends_on = [aws_api_gateway_rest_api.custom_identity_provider_rest_api]
}

# Stage
resource "aws_api_gateway_stage" "custom_identity_provider_stage" {
  deployment_id = aws_api_gateway_deployment.custom_identity_provider_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.custom_identity_provider_rest_api.id
  stage_name    = "prod"
}

# Deployment
resource "aws_api_gateway_deployment" "custom_identity_provider_deployment" {
  rest_api_id = aws_api_gateway_rest_api.custom_identity_provider_rest_api.id
  stage_name  = "dummystagefordeployment"

  depends_on = [
    aws_api_gateway_integration.get_user_config_integration,
    aws_api_gateway_integration_response.get_user_config_integration_response
  ]
}

# Resouce
resource "aws_api_gateway_resource" "servers_resource" {
  parent_id   = aws_api_gateway_rest_api.custom_identity_provider_rest_api.root_resource_id
  path_part   = "servers"
  rest_api_id = aws_api_gateway_rest_api.custom_identity_provider_rest_api.id
}

resource "aws_api_gateway_resource" "server_id_resource" {
  parent_id   = aws_api_gateway_resource.servers_resource.id
  path_part   = "{serverId}"
  rest_api_id = aws_api_gateway_rest_api.custom_identity_provider_rest_api.id
}

resource "aws_api_gateway_resource" "users_resource" {
  parent_id   = aws_api_gateway_resource.server_id_resource.id
  path_part   = "users"
  rest_api_id = aws_api_gateway_rest_api.custom_identity_provider_rest_api.id
}

resource "aws_api_gateway_resource" "user_name_resource" {
  parent_id   = aws_api_gateway_resource.users_resource.id
  path_part   = "{username}"
  rest_api_id = aws_api_gateway_rest_api.custom_identity_provider_rest_api.id
}

resource "aws_api_gateway_resource" "get_user_config_resource" {
  parent_id   = aws_api_gateway_resource.user_name_resource.id
  path_part   = "config"
  rest_api_id = aws_api_gateway_rest_api.custom_identity_provider_rest_api.id
}

# Method settings
resource "aws_api_gateway_method_settings" "custom_identity_provider" {
  method_path = "*/*"
  rest_api_id = aws_api_gateway_rest_api.custom_identity_provider_rest_api.id
  stage_name  = aws_api_gateway_stage.custom_identity_provider_stage.stage_name

  settings {
    data_trace_enabled = false
    logging_level      = "INFO"
  }
}

# Method
resource "aws_api_gateway_method" "get_user_config_method" {
  authorization = "AWS_IAM"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.get_user_config_resource.id
  rest_api_id   = aws_api_gateway_rest_api.custom_identity_provider_rest_api.id

  request_parameters = {
    "method.request.header.Password" = false
  }

  depends_on = [aws_api_gateway_model.get_user_config_model]
}

# Method Response
resource "aws_api_gateway_method_response" "get_user_config_method_response" {
  http_method = aws_api_gateway_method.get_user_config_method.http_method
  resource_id = aws_api_gateway_resource.get_user_config_resource.id
  rest_api_id = aws_api_gateway_rest_api.custom_identity_provider_rest_api.id
  status_code = "200"

  response_models = {
    "application/json" = aws_api_gateway_model.get_user_config_model.name
  }
}

# Integration
resource "aws_api_gateway_integration" "get_user_config_integration" {
  http_method             = aws_api_gateway_method.get_user_config_method.http_method
  resource_id             = aws_api_gateway_resource.get_user_config_resource.id
  rest_api_id             = aws_api_gateway_rest_api.custom_identity_provider_rest_api.id
  type                    = "AWS"
  uri                     = aws_lambda_function.get_user_config_lambda_function.invoke_arn
  integration_http_method = "POST"

  request_templates = {
    "application/json" = <<EOF
{
  "username": "$input.params('username')",
  "password": "$util.escapeJavaScript($input.params('Password')).replaceAll("\\'","'")",
  "serverId": "$input.params('serverId')"
}
EOF
  }
}

# Integration response
resource "aws_api_gateway_integration_response" "get_user_config_integration_response" {
  http_method = aws_api_gateway_method.get_user_config_method.http_method
  resource_id = aws_api_gateway_resource.get_user_config_resource.id
  rest_api_id = aws_api_gateway_rest_api.custom_identity_provider_rest_api.id
  status_code = aws_api_gateway_method_response.get_user_config_method_response.status_code

  depends_on = [aws_api_gateway_integration.get_user_config_integration]
}

# Model
resource "aws_api_gateway_model" "get_user_config_model" {
  content_type = "application/json"
  name         = "getUserConfigModel"
  rest_api_id  = aws_api_gateway_rest_api.custom_identity_provider_rest_api.id

  schema = <<EOF
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "UserUserConfig",
  "type": "object",
  "properties": {
    "Role": {
      "type": "string"
    },
    "Policy": {
      "type": "string"
    },
    "HomeDirectory": {
      "type": "string"
    },
    "PublicKeys": {
      "type": "array",
      "items": {
        "type": "string"
      }
    }
  }
}
EOF
}

## Lambda
data "archive_file" "get_user_config_archive_file" {
  type        = "zip"
  source_dir  = local.source_dir
  output_path = local.output_path
}

resource "aws_lambda_function" "get_user_config_lambda_function" {
  function_name = "${var.name_prefix}get-user-config"
  role          = var.iam_role_lambda_basic_execution_arn

  handler          = "index.handler"
  runtime          = var.lambda_runtime
  publish          = true
  filename         = data.archive_file.get_user_config_archive_file.output_path
  source_code_hash = data.archive_file.get_user_config_archive_file.output_base64sha256

  memory_size = 128
  timeout     = 30

  environment {
    variables = {
      userName          = var.user_name
      userHomeDirectory = var.user_home_directory
      userRoleArn       = aws_iam_role.transfer_s3_access.arn
      userPassword      = var.user_password
      userPublickKey1   = var.user_public_key_1
    }
  }
}

resource "aws_lambda_permission" "get_user_config_lambda_permission" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user_config_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.custom_identity_provider_rest_api.execution_arn}/*"
}

resource "aws_cloudwatch_log_group" "get_user_config_log_group" {
  name              = "/aws/lambda/${var.name_prefix}get-user-config"
  retention_in_days = 90
}

# IAM Role
resource "aws_iam_role" "transfer_s3_access" {
  name = "${var.name_prefix}transfer-s3-access-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "transfer.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "transfer_identity_provider_invocation" {
  name = "${var.name_prefix}transfer-identity-provider-invocation-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "transfer.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM Policy
resource "aws_iam_policy" "transfer_s3_bucket_access" {
  name        = "${var.name_prefix}transfer-s3-bucket-access-policy"
  path        = "/"
  description = "Transfer access to S3 Buckets"

  policy = data.aws_iam_policy_document.transfer_s3_bucket_access.json
}

resource "aws_iam_policy" "transfer_s3_object_access" {
  name        = "${var.name_prefix}transfer-s3-object-access-policy"
  path        = "/"
  description = "Transfer access to S3 Objects"

  policy = data.aws_iam_policy_document.transfer_s3_object_access.json
}

resource "aws_iam_policy" "transfer_can_invoke_api" {
  name        = "${var.name_prefix}transfer-can-invoke-api-policy"
  path        = "/"
  description = "Transfer can invoke api"

  policy = data.aws_iam_policy_document.transfer_can_invoke_api.json
}

resource "aws_iam_policy" "transfer_can_read_api" {
  name        = "${var.name_prefix}transfer-can-read-api-policy"
  path        = "/"
  description = "Transfer can read api"

  policy = data.aws_iam_policy_document.transfer_can_read_api.json
}

# IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "transfer_s3_bucket_access" {
  policy_arn = aws_iam_policy.transfer_s3_bucket_access.arn
  role       = aws_iam_role.transfer_s3_access.name
}

resource "aws_iam_role_policy_attachment" "transfer_s3_object_access" {
  policy_arn = aws_iam_policy.transfer_s3_object_access.arn
  role       = aws_iam_role.transfer_s3_access.name
}

resource "aws_iam_role_policy_attachment" "transfer_can_invoke_api" {
  policy_arn = aws_iam_policy.transfer_can_invoke_api.arn
  role       = aws_iam_role.transfer_identity_provider_invocation.name
}

resource "aws_iam_role_policy_attachment" "transfer_can_read_api" {
  policy_arn = aws_iam_policy.transfer_can_read_api.arn
  role       = aws_iam_role.transfer_identity_provider_invocation.name
}

# IAM Policy Document
data "aws_iam_policy_document" "transfer_s3_bucket_access" {
  statement {
    sid = "transferS3BucketAccess"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      var.s3_bucket_arn
    ]
  }
}

data "aws_iam_policy_document" "transfer_s3_object_access" {
  statement {
    sid = "transferS3ObjectAccess"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetObjectVersion",
      "s3:GetObjectACL",
      "s3:PutObjectACL"
    ]

    resources = [
      "${var.s3_bucket_arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "transfer_can_invoke_api" {
  statement {
    sid = "transferCanInvokeApi"

    actions = [
      "execute-api:Invoke"
    ]

    resources = ["${aws_api_gateway_rest_api.custom_identity_provider_rest_api.execution_arn}/prod/GET/*"]
  }
}

data "aws_iam_policy_document" "transfer_can_read_api" {
  statement {
    sid = "transferCanReadApi"

    actions = [
      "apigateway:GET"
    ]

    resources = ["*"]
  }
}
