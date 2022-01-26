data "aws_iam_policy_document" "assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "permissions" {
  policy = var.permissions
}

resource "aws_iam_role_policy_attachment" "permission" {
  role       = aws_iam_role.role.id
  policy_arn = aws_iam_policy.permissions.arn
}

resource "aws_iam_role_policy_attachment" "permission_basic" {
  role       = aws_iam_role.role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "create_eni" { // Need this to be able to put to a VPC...
  count = var.vpc_config == null ? 0 : 1

  role       = aws_iam_role.role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role" "role" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_cloudwatch_log_group" "sample" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 7
}

resource "aws_lambda_function" "lambda" {
  function_name    = var.name
  source_code_hash = base64sha256(filebase64("${path.module}/blank.zip"))
  filename         = "${path.module}/blank.zip"
  handler          = "index.handle"
  runtime          = "nodejs12.x"
  timeout          = 30
  memory_size      = 128
  role             = aws_iam_role.role.arn
    
  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [var.vpc_config]
    content {
      security_group_ids = vpc_config.value.security_group_ids
      subnet_ids         = vpc_config.value.subnet_ids
    }
  }

  environment {
    variables = var.variables
  }

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
      last_modified
    ]
  }
}