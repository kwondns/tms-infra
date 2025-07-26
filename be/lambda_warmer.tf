resource "aws_cloudwatch_event_rule" "timeline_chatbot_lambda_warmer_rule" {
  name                = "timeline-chatbot-warmer"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "timeline_chatbot_lambda_warmer_target" {
  arn  = aws_lambda_function.timeline_chatbot.arn
  rule = aws_cloudwatch_event_rule.timeline_chatbot_lambda_warmer_rule.name
  input = jsonencode({ warmer = true })
  target_id = "timeline-chatbot-warmer"
}

resource "aws_lambda_permission" "allow_eventbridge_invoke" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.timeline_chatbot.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.timeline_chatbot_lambda_warmer_rule.arn
}
