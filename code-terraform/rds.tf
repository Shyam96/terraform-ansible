resource "aws_db_subnet_group" "subnetgrp" {
  name       = "${var.vpc_id}-rds-dbsubnetgroup"
  subnet_ids = ["${split(",",var.private_subnets)}"]

}

data "aws_kms_secrets" "example" {
  secret {
    name    = "master_password"
    payload ="########################################################"
    context = {
      foo = "bar"
    }
  }
}

resource "aws_security_group" "rds-mysql-sg" {
  name = "${var.namespace}-rds-mysql-sg"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_db_instance" "mysqlrds" {
  allocated_storage        = 100
  storage_type             = "gp2"
  engine                   = "mysql"
  engine_version           = "5.7.21"
  instance_class           = "db.t2.medium"
  storage_encrypted        = true
  final_snapshot_identifier = "${var.namespace}-dbmysql-final-snapshot"
  identifier               = "${var.namespace}-dbmysql"
  copy_tags_to_snapshot    = true
  backup_window            = "11:28-11:58"
  backup_retention_period  = 7
  name                     = "TestDb"
  username                 = "TestUser"
  password                 = "${data.aws_kms_secrets.example.plaintext["master_password"]}"
  multi_az			       = true
  db_subnet_group_name     = "${aws_db_subnet_group.subnetgrp.name}"
  parameter_group_name     = "default.mysql5.7"
  vpc_security_group_ids   = ["${aws_security_group.rds-mysql-sg.id}"]
}

output "rds_endpoint" {
  value = "${aws_db_instance.mysqlrds.endpoint}"
}
