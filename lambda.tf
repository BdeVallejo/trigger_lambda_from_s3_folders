locals {
  zip_code_name = "sample-lambda.zip"
  lambda_name   = "sample-lambda"
}

locals {
  zip_code_name = "sample-lambda-2.zip"
  lambda_name   = "sample-lambda-2"
}

data "archive_file" "sample-lambda_code_zip" {
  type        = "zip"
  source_dir  = "${path.module}/sample-lambda/"
  output_path = "${path.module}/${local.zip_code_name}"
}

data "archive_file" "sample-lambda-2_code_zip" {
  type        = "zip"
  source_dir  = "${path.module}/sample-lambda-2/"
  output_path = "${path.module}/${local.zip_code_name}"
}

data "aws_iam_policy_document" "sample_lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "sample_lambda" {
  name               = "sampleLambda"
  assume_role_policy = data.aws_iam_policy_document.sample_lambda_assume_role.json
}

data "aws_iam_policy_document" "sample_lambda_s3_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [aws_s3_bucket.example_bucket.arn]
  }
}

resource "aws_iam_policy" "sample_lambda_iam_policy {
  name        = "lambda_s3_actions"
  path        = "/"
  description = "IAM policy for s3 actions"
  policy      = data.aws_iam_policy_document.sample_lambda_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "sample_lambda_s3" {
  role       = aws_iam_role.sample_lambda.name
  policy_arn = aws_iam_policy.sample_lambda_iam_policy.arn
}

resource "aws_lambda_function" "sample_lambda" {
  filename         = local.zip_code_name
  function_name    = local.sample-lambda
  role             = aws_iam_role.sample_lambda.arn
  handler          = "index.handler"
  timeout          = 8 * 60
  source_code_hash = data.archive_file.sample_lambda_code_zip.output_base64sha256

  runtime = "nodejs18.x"
  environment {
    variables = {
      REGION      = "eu-west-1"
      ENVIRONMENT = "dev"
    }
  }
}

resource "aws_lambda_function" "sample_lambda_2" {
  filename         = local.zip_code_name
  function_name    = local.sample-lambda-2
  role             = aws_iam_role.sample_lambda.arn
  handler          = "index.handler"
  timeout          = 8 * 60
  source_code_hash = data.archive_file.sample-lambda-2_code_zip.output_base64sha256

  runtime = "nodejs18.x"
  environment {
    variables = {
      REGION      = "eu-west-1"
      ENVIRONMENT = "dev"
    }
  }
}

resource "aws_lambda_permission" "allow_sample_lambda_invoke" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sample_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.example_bucket.arn
}

resource "aws_lambda_permission" "allow_sample_lambda_2_invoke" {
  statement_id  = "AllowExecutionFromS3BucketConsolidation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sample_lambda_2.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.example_bucket.arn
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.example_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.sample_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "folder-1/"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.sample_lambda_2.arn
    events              = ["s3:ObjectRemoved:*"]
    filter_prefix       = "folder-2/"
  }

  depends_on = [
    aws_lambda_permission.allow_sample_lambda_invoke,
    aws_lambda_permission.allow_sample_lambda_2_invoke
  ]
}
