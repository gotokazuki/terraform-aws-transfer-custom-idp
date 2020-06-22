variable "s3_bucket_arn" {
  description = "The arn of the S3 bucket used for the Transfer Server"
  type        = string
}
variable "iam_role_apigw_logging_arn" {
  description = "The arn of the IAM Role used by the API Gateway for logging"
  type        = string
}
variable "iam_role_lambda_basic_execution_arn" {
  description = "The arn of the IAM Role used by the Lambda for executing lambda functions"
  type        = string
}
variable "name_prefix" {
  description = "String to use as a prefix for the object names"
  type        = string
  default     = ""
}
variable "lambda_runtime" {
  description = "lambda runtime"
  type        = string
  default     = "nodejs12.x"
}
variable "lambda_get_user_config_function_source_dir" {
  description = "The source dir of the lambda function"
  type        = string
  default     = "use_default_function"
}
variable "lambda_get_user_config_function_output_path" {
  description = "The output path of the lambda function"
  type        = string
  default     = "use_default_function"
}
variable "user_name" {
  description = "userName in lambda function"
  type        = string
  default     = "myuser"
}
variable "user_home_directory" {
  description = "userHomeDirectory in lambda function"
  type        = string
  default     = "/"
}
variable "user_password" {
  description = "userPassword in lambda function"
  type        = string
  default     = "MySuperSecretPassword"
}
variable "user_public_key_1" {
  description = "userPublicKey1 in lambda functio"
  type        = string
  default     = "ssh-rsa myrsapubkey"
}
