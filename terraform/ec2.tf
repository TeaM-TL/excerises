resource "aws_instance" "wordpress" {
  availability_zone = "eu-central-1a"
  ami               = "ami-076bdd070268f9b8d"
  instance_type     = "t2.micro"

  associate_public_ip_address = true

  key_name = aws_key_pair.superadmin.key_name

  user_data = templatefile(
    "start.sh",
    {
      db_host = aws_rds_cluster.mysql.endpoint,
      db_user = aws_rds_cluster.mysql.master_username,
      db_pass = aws_rds_cluster.mysql.master_password,
      db_name = aws_rds_cluster.mysql.database_name
    }
  )

  user_data_replace_on_change = true

  vpc_security_group_ids = [
    aws_security_group.internal.id,
    aws_security_group.allow_ssh.id,
    aws_security_group.out.id
  ]

  root_block_device {
    volume_size = "100"
  }
}

output "ec2_instance_host" {
  value = aws_instance.wordpress.public_dns
}

resource "aws_key_pair" "superadmin" {
  key_name   = "superadmin"
  public_key = file("superadmin.pub")
}