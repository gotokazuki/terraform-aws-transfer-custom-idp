output "apigw_deployment_invoke_url" {
  value = aws_api_gateway_deployment.custom_identity_provider_deployment.invoke_url
}
