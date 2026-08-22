resource "aws_security_group" "palworld" {
  name        = "palworld-sg"
  description = "launch-wizard-2 created 2026-08-17T16:39:05.292Z"
  vpc_id      = var.vpc_id

  ingress {
    description = "Palworld game traffic"
    from_port   = 8211
    to_port     = 8211
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.home_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_eip" "palworld" {
  domain = "vpc"
}