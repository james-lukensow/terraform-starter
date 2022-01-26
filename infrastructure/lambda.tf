locals {
  variables = merge({
    REGION                     = data.aws_region.current.name
  })
}

# Sample lambda (BEGIN)
data "aws_iam_policy_document" "sample" {
  statement {
    effect    = "Allow"
    resources = [
      "*"
    ]
    actions   = [
      "*"
    ]    
  }
}

module "sample_lambda" {
  source = "../shared/terraform/lambda"

  name        = "${local.prefix}-sample"
  permissions = data.aws_iam_policy_document.sample.json
  timeout     = 30
  memory_size = 128
  variables   = local.variables
}
# Sample lambda (END)

