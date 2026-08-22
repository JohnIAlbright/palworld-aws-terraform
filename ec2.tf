resource "aws_instance" "palworld" {
  ami                    = "ami-0b6d9d3d33ba97d99"
  instance_type          = "t3.large"
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.palworld.id]

  iam_instance_profile = aws_iam_instance_profile.palworld_ec2.name

  user_data_replace_on_change = false

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
  }

  tags = {
    Name = "Palworld-Prod-Server"
  }
}