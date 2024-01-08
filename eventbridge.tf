resource "aws_cloudwatch_event_rule" "start_event_rule" {
  name                = "start-ec2"
  schedule_expression = "cron(0 10 * * ? *)" # 10:00UTC daily
}

resource "aws_cloudwatch_event_target" "start_event_lambda_target" {
  rule  = aws_cloudwatch_event_rule.start_event_rule.name
  arn   = aws_lambda_function.lambda_startStopEC2_func.arn
  input = <<EOF
{
  "action": "start",
  "region": "eu-west-1",
  "instances": ["ExampleAppServerInstance"]
}
  EOF
}

resource "aws_lambda_permission" "allow_startstop_event_rule_schedule" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_startStopEC2_func.function_name
  principal     = "events.amazonaws.com"
}

resource "aws_cloudwatch_event_rule" "stop_event_rule" {
  name                = "stop-ec2"
  schedule_expression = "cron(30 16 * * ? *)" # 16:30UTC daily
}

resource "aws_cloudwatch_event_target" "stop_event_lambda_target" {
  rule  = aws_cloudwatch_event_rule.stop_event_rule.name
  arn   = aws_lambda_function.lambda_startStopEC2_func.arn
  input = <<EOF
{
  "action": "stop",
  "region": "eu-west-1",
  "instances": ["ExampleAppServerInstance"]
}
  EOF
}

