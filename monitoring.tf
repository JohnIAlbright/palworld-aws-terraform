resource "aws_sns_topic" "palworld_alerts" {
  name = "PalWorldServerAlerts"
}

resource "aws_sns_topic_subscription" "palworld_alerts_email" {
  topic_arn = aws_sns_topic.palworld_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email

  confirmation_timeout_in_minutes = 1
  endpoint_auto_confirms          = false
}
resource "aws_cloudwatch_metric_alarm" "palworld_high_cpu" {
  alarm_name          = "PalWorldHighCPU"
  alarm_description   = "PalWorld EC2 CPU Utilization above 85% for 15 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  threshold           = 85
  period              = 300
  statistic           = "Average"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  treat_missing_data  = "missing"

  dimensions = {
    InstanceId = aws_instance.palworld.id
  }

  alarm_actions = [
    aws_sns_topic.palworld_alerts.arn
  ]
}
resource "aws_cloudwatch_metric_alarm" "palworld_memory" {
  alarm_name          = "mem_used_percent"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  threshold           = 85
  period              = 300
  statistic           = "Average"
  namespace           = "CWAgent"
  metric_name         = "mem_used_percent"
  treat_missing_data  = "missing"

  dimensions = {
    InstanceId = aws_instance.palworld.id
  }

  alarm_actions = [
    aws_sns_topic.palworld_alerts.arn
  ]
}
resource "aws_cloudwatch_metric_alarm" "palworld_disk" {
  alarm_name          = "disk_used_percent"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  threshold           = 80
  period              = 300
  statistic           = "Average"
  namespace           = "CWAgent"
  metric_name         = "disk_used_percent"
  treat_missing_data  = "missing"

  dimensions = {
    InstanceId = aws_instance.palworld.id
  }

  alarm_actions = [
    aws_sns_topic.palworld_alerts.arn
  ]
}