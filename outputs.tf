output "apigw_deployment_invoke_url" {
  description = "The invoke url used by IdP of Transfer Server"
  value       = aws_api_gateway_deployment.custom_identity_provider_deployment.invoke_url
}
