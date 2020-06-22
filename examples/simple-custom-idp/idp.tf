module "idp" {
  source = "git::https://github.com/gotooooo/terraform-aws-transfer-custom-idp.git?ref=0.0.1"

  s3_bucket_arn                       = aws_s3_bucket.bucket.arn
  iam_role_apigw_logging_arn          = aws_iam_role.apigw_logging.arn
  iam_role_lambda_basic_execution_arn = aws_iam_role.lambda_basic_execution.arn
}
