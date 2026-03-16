resource "aws_iam_role" "scheduler_ec2_role" {
  name = "scheduler-ec2-start-stop-role"

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
  name = "scheduler-ec2-start-stop-policy"
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
        Resource = aws_instance.k8s_main.arn
      }
    ]
  })
}

resource "aws_scheduler_schedule" "start_ec2_morning" {
  name       = "start-k8s-main-morning"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 8 * * ? *)"
  schedule_expression_timezone = "Europe/Bucharest"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.scheduler_ec2_role.arn

    input = jsonencode({
      InstanceIds = [aws_instance.k8s_main.id]
    })
  }
}

resource "aws_scheduler_schedule" "stop_ec2_night" {
  name       = "stop-k8s-main-night"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 23 * * ? *)"
  schedule_expression_timezone = "Europe/Bucharest"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.scheduler_ec2_role.arn

    input = jsonencode({
      InstanceIds = [aws_instance.k8s_main.id]
    })
  }
}