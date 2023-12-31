terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0eb11ab33f229b26c"
  instance_type = "t2.nano"

  tags = {
    Name = var.instance_name
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.ec2_stopstart_policy.arn
}

resource "aws_iam_policy" "ec2_stopstart_policy" {
  name        = "ec2-stopstart-policy"
  description = "EC2 Stop-Start Policy"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:Start*",
        "ec2:Stop*"
      ],
      "Resource": "*"
    }
  ]
}
EOT
}

data "archive_file" "startStopEC2_zip" {
  type        = "zip"
  source_file = "./lambda/startStopEC2.py"
  output_path = "./lambda/startStopEC2.zip"
}

resource "aws_lambda_function" "lambda_startStopEC2_func" {
  filename      = "./lambda/startStopEC2.zip"
  function_name = "StartStop_EC2_func"
  role          = aws_iam_role.lambda_role.arn
  handler       = "startStopEC2.lambda_handler"
  runtime       = "python3.9"
  depends_on    = [aws_iam_role_policy_attachment.lambda_attachment]
}
