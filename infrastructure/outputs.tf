output "region" {
  value = var.primaryRegion
}

output "aws_cluster_name" {
  value = aws_ecs_cluster.terraform_cluster.name
}

output "aws_service_api_name" {
  value = aws_ecs_service.terraform_api_service.name
}

output "aws_repo_api_url" {
  value = aws_ecr_repository.terraform_api_repo.repository_url
}

output "aws_repo_api_name" {
  value = aws_ecr_repository.terraform_api_repo.name
}

output "aws_ecs_api_task_family" {
  value = aws_ecs_task_definition.terraform_api_task.family
}

output "aws_ecs_execution_role" {
  value = aws_iam_role.ecsTaskExecutionRole.arn
}

output "aws_local_prefix" {
  value = local.prefix
}

output "aws_ecs_definition_cpu" {
  value = var.ecsDefinitionCpu
}

output "aws_ecs_definition_memory" {
  value = var.ecsDefinitionMemory
}

output "code_bucket_name" {
  value = aws_s3_bucket.code.id
}

output "sample_lambda_function" {  
  value = module.sample_lambda.lambda.function_name
}