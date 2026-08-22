data "archive_file" "palworld_shutdown" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.py"
  output_path = "${path.module}/palworld-shutdown.zip"
}

resource "aws_lambda_function" "palworld_nightly_shutdown" {
  function_name = "PalworldNightlyShutdown"

  filename         = data.archive_file.palworld_shutdown.output_path
  source_code_hash = data.archive_file.palworld_shutdown.output_base64sha256

  role    = aws_iam_role.palworld_shutdown_lambda.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.14"

  memory_size = 128
  timeout     = 30

  architectures = ["x86_64"]

  environment {
    variables = {
      INSTANCE_ID = aws_instance.palworld.id
    }
  }
}

resource "aws_scheduler_schedule" "palworld_nightly_shutdown" {
  name       = "PalWorldNightlyShutdown"
  group_name = "default"

  description                  = ""
  state                        = "ENABLED"
  schedule_expression          = "cron(0 3 * * ? *)"
  schedule_expression_timezone = "America/New_York"
  action_after_completion      = "NONE"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.palworld_nightly_shutdown.arn
    role_arn = aws_iam_role.palworld_scheduler.arn

    retry_policy {
      maximum_event_age_in_seconds = 86400
      maximum_retry_attempts       = 0
    }
  }
}