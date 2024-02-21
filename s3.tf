resource "aws_s3_bucket" "example_bucket" {
  bucket = var.bucket_name

  tags = {
    Environment = "Development"
    Project     = "Test"
  }
}


resource "aws_s3_bucket_object" "folder-1" {
  bucket = aws_s3_bucket.example_bucket.id
  key    = "folder-1/"
}

resource "aws_s3_bucket_object" "folder-2" {
  bucket = aws_s3_bucket.example_bucket.id
  key    = "folder-2/"
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.example_bucket.id
  policy = data.aws_iam_policy_document.main.json
}

data "aws_iam_policy_document" "main" {

  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "${aws_s3_bucket.example_bucket.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}