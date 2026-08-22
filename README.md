\# Palworld Dedicated Server on AWS



A production-style Palworld dedicated server hosted on AWS and managed with Terraform.



This project began as a manually configured EC2 game server and was later migrated to Infrastructure as Code using Terraform. The environment includes automated backups, monitoring and alerting, remote management, and an automated graceful nightly shutdown process designed to reduce unnecessary compute costs while protecting game data.



\## Architecture



The environment uses the following AWS services:



\- \*\*Amazon EC2\*\* — Hosts the Palworld dedicated server

\- \*\*Amazon EBS\*\* — Provides persistent gp3 storage for the server

\- \*\*Elastic IP\*\* — Provides a consistent public IP for player connections

\- \*\*Amazon S3\*\* — Stores automated Palworld world backups

\- \*\*AWS Systems Manager (SSM)\*\* — Provides remote server management and allows Lambda to execute graceful shutdown commands

\- \*\*AWS Lambda\*\* — Coordinates the automated nightly shutdown process

\- \*\*Amazon EventBridge Scheduler\*\* — Invokes the shutdown Lambda function on a nightly schedule

\- \*\*Amazon CloudWatch\*\* — Monitors CPU, memory, and disk utilization

\- \*\*Amazon SNS\*\* — Sends email notifications when monitoring thresholds are exceeded

\- \*\*AWS IAM\*\* — Provides least-privilege permissions between AWS services

\- \*\*Terraform\*\* — Manages the AWS infrastructure as code



\## Server Infrastructure



The Palworld server runs on an Amazon EC2 `t3.large` instance with:



\- 2 vCPUs

\- 8 GiB RAM

\- 30 GB gp3 EBS root volume

\- Elastic IP for a persistent public endpoint

\- UDP port `8211` exposed for Palworld game traffic

\- SSH access restricted to an administrator IP address



The EC2 instance uses an IAM instance profile that allows it to:



\- Upload and retrieve backups from the designated S3 bucket

\- Communicate with AWS Systems Manager

\- Publish system metrics through the CloudWatch Agent



\## Automated Backups



Palworld world data is backed up to Amazon S3.



The S3 configuration includes:



\- Bucket versioning

\- Public access blocking

\- A 30-day lifecycle policy for backups

\- 30-day expiration of noncurrent object versions



The EC2 IAM policy limits S3 permissions to the dedicated backup bucket.



\## Monitoring and Alerting



CloudWatch monitors server health using both native EC2 metrics and the CloudWatch Agent.



Configured alarms include:



| Metric | Threshold | Duration |

| --- | --- | --- |

| CPU utilization | > 85% | 15 minutes |

| Memory utilization | > 85% | 15 minutes |

| Disk utilization | > 80% | 15 minutes |



When an alarm enters the alarm state, Amazon SNS sends an email notification to the administrator.



\## Automated Graceful Shutdown



The server automatically shuts down nightly to avoid paying for EC2 compute when the game server is not needed.



The shutdown workflow is:



1\. EventBridge Scheduler invokes the shutdown Lambda function.

2\. Lambda checks whether the EC2 instance is running.

3\. Lambda uses AWS Systems Manager to execute a shutdown command on the server.

4\. The Palworld systemd service is stopped gracefully.

5\. Lambda checks the SSM command result.

6\. After the game server has been given time to shut down safely, Lambda stops the EC2 instance.



This approach avoids simply terminating EC2 compute while the Palworld server process is actively writing world data.



\## Infrastructure as Code



The AWS environment is managed using Terraform.



The Terraform configuration is separated by responsibility:



```text

.

├── ec2.tf

├── iam.tf

├── lambda.tf

├── monitoring.tf

├── networking.tf

├── outputs.tf

├── providers.tf

├── s3.tf

├── variables.tf

└── lambda/

&#x20;   └── lambda\_function.py

