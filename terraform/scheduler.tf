resource "aws_iam_role" "scheduler_ec2_role" {
  name = "scheduler-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "scheduler_ec2_policy" {
  name = "scheduler-ec2-policy"
  role = aws_iam_role.scheduler_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = aws_instance.k8s_devstaging.arn
      }
    ]
  })
}

resource "aws_scheduler_schedule" "start_ec2_morning" {
  name                         = "start-k8s-dev-staging-morning"
  group_name                   = "default"
  schedule_expression          = "cron(0 6 ? * MON-FRI *)"
  schedule_expression_timezone = "Europe/Bucharest"
  state                        = "ENABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.scheduler_ec2_role.arn

    input = jsonencode({
      InstanceIds = [aws_instance.k8s_devstaging.id]
    })
  }
}

resource "aws_scheduler_schedule" "stop_ec2_night" {
  name                         = "stop-k8s-dev-staging-night"
  group_name                   = "default"
  schedule_expression          = "cron(0 22 ? * MON-FRI *)"
  schedule_expression_timezone = "Europe/Bucharest"
  state                        = "ENABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.scheduler_ec2_role.arn

    input = jsonencode({
      InstanceIds = [aws_instance.k8s_devstaging.id]
    })
  }
}