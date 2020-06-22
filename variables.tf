variable "s3_bucket_arn" {}
variable "iam_role_apigw_logging_arn" {}
variable "iam_role_lambda_basic_execution_arn" {}
variable "name_prefix" { default = "" }
variable "lambda_runtime" { default = "nodejs12.x" }
variable "lambda_get_user_config_function_source_dir" { default = "use_default_function" }
variable "lambda_get_user_config_function_output_path" { default = "use_default_function" }
variable "user_name" { default = "myuser" }
variable "user_home_directory" { default = "/" }
variable "user_password" { default = "MySuperSecretPassword" }
variable "user_public_key_1" { default = "ssh-rsa myrsapubkey" }
