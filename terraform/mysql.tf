resource "random_password" "mysql" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_rds_cluster" "mysql" {
  cluster_identifier      = "wp-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.11.0"
  availability_zones      = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  database_name           = "wp_db"
  master_username         = "wp_user"
  master_password         = random_password.mysql.result
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true

  vpc_security_group_ids = [
    aws_security_group.internal.id,
    aws_security_group.allow_mysql.id
  ]
}

resource "aws_rds_cluster_instance" "mysql_instances" {
  count = 2

  identifier          = "wp-cluster-${count.index}"
  cluster_identifier  = aws_rds_cluster.mysql.id
  instance_class      = "db.t2.small"
  engine              = aws_rds_cluster.mysql.engine
  engine_version      = aws_rds_cluster.mysql.engine_version
  publicly_accessible = true
}

output "mysql_host" {
  value = aws_rds_cluster.mysql.endpoint
}

output "mysql_password" {
  sensitive = true
  value     = aws_rds_cluster.mysql.master_password
}