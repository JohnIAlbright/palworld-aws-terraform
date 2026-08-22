resource "aws_iam_role" "palworld_ec2" {
  name                 = "PalworldEC2BackupRole"
  path                 = "/"
  description          = "Allows EC2 instances to call AWS services on your behalf."
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_instance_profile" "palworld_ec2" {
  name = "PalworldEC2BackupRole"
  role = aws_iam_role.palworld_ec2.name
}
resource "aws_iam_policy" "palworld_s3_backup" {
  name = "PalworldS3BackupPolicy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ListBackupBucket"
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.palworld_backups.arn
      },
      {
        Sid    = "ManageBackupObjects"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.palworld_backups.arn}/*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "palworld_s3_backup" {
  role       = aws_iam_role.palworld_ec2.name
  policy_arn = aws_iam_policy.palworld_s3_backup.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.palworld_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.palworld_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role" "palworld_shutdown_lambda" {
  name                 = "PalworldNightlyShutdown-role-0opd17ay"
  path                 = "/service-role/"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_policy" "palworld_lambda_logs" {
  name = "AWSLambdaBasicExecutionRole-70b2b982-147d-46a0-9c32-3cced81f253b"
  path = "/service-role/"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect   = "Allow"
        Action   = "logs:CreateLogGroup"
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.palworld_nightly_shutdown.function_name}:*"
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "palworld_lambda_logs" {
  role       = aws_iam_role.palworld_shutdown_lambda.name
  policy_arn = aws_iam_policy.palworld_lambda_logs.arn
}
resource "aws_iam_role_policy" "palworld_ec2_stop" {
  name = "PalWorldEC2StopPolicy"
  role = aws_iam_role.palworld_shutdown_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect   = "Allow"
        Action   = "ec2:StopInstances"
        Resource = aws_instance.palworld.arn
      },
      {
        Effect   = "Allow"
        Action   = "ec2:DescribeInstances"
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy" "palworld_ssm_shutdown" {
  name = "PalWorldSSMShutdownPolicy"
  role = aws_iam_role.palworld_shutdown_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "SendPalworldShutdownCommand"
        Effect = "Allow"
        Action = "ssm:SendCommand"

        Resource = [
          aws_instance.palworld.arn,
          "arn:aws:ssm:${var.aws_region}::document/AWS-RunShellScript"
        ]
      },
      {
        Sid      = "CheckCommandStatus"
        Effect   = "Allow"
        Action   = "ssm:GetCommandInvocation"
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role" "palworld_scheduler" {
  name                 = "EventBridgeScheduler-PalworldShutdownRole"
  path                 = "/service-role/"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "scheduler.amazonaws.com"
        }

        Action = "sts:AssumeRole"

        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}
resource "aws_iam_policy" "palworld_scheduler_invoke" {
  name = "Amazon-EventBridge-Scheduler-Execution-Policy-d17ecdca-2f81-430f-86c9-ef38e5c0c8b5"
  path = "/service-role/"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "lambda:InvokeFunction"
        ]

        Resource = [
          "${aws_lambda_function.palworld_nightly_shutdown.arn}:*",
          aws_lambda_function.palworld_nightly_shutdown.arn
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "palworld_scheduler_invoke" {
  role       = aws_iam_role.palworld_scheduler.name
  policy_arn = aws_iam_policy.palworld_scheduler_invoke.arn
}
