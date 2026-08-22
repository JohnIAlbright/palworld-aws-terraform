output "palworld_instance_id" {
  description = "EC2 instance ID for the Palworld server"
  value       = aws_instance.palworld.id
}

output "palworld_elastic_ip" {
  description = "Elastic IP address for the Palworld server"
  value       = aws_eip.palworld.public_ip
}

output "backup_bucket_name" {
  description = "S3 bucket storing Palworld backups"
  value       = aws_s3_bucket.palworld_backups.id
}

output "shutdown_lambda_name" {
  description = "Lambda function used for graceful nightly shutdown"
  value       = aws_lambda_function.palworld_nightly_shutdown.function_name
}

output "shutdown_schedule_name" {
  description = "EventBridge Scheduler schedule for nightly shutdown"
  value       = aws_scheduler_schedule.palworld_nightly_shutdown.name
}

output "alerts_topic_arn" {
  description = "SNS topic used for Palworld monitoring alerts"
  value       = aws_sns_topic.palworld_alerts.arn
}