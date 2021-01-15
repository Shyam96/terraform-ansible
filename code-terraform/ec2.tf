data "template_file" "user_data" {
  template = "${file("${path.module}/userdata/test.sh")}"
}
######********* Launch Configuration ***********#####
resource "aws_launch_configuration" "as_conf" {
  name_prefix = "${var.namespace}-server"
  image_id = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "t2.micro"
  security_groups = [
    "${aws_security_group.instance-sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.id}"
  key_name = "test-key"
  user_data = "${data.template_file.user_data.rendered}"
  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type = "gp2"
    volume_size = 100
  }
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "${var.namespace}-profile"
  path = "/${var.namespace}/"
  role = "${aws_iam_role.instance_role.id}"
  lifecycle {
    ignore_changes = [
      "path"]
  }
}

#***** Security Group ******#####
resource "aws_security_group" "instance-sg" {
  name = "${var.namespace}-sg"
  description = "Allow https traffic"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
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

####**** Autoscaling for ec2 launch ***
resource "aws_autoscaling_group" "tbdevtf-cep-layer-ASG" {
  vpc_zone_identifier = [
    "${split(",", var.private_subnets)}"]
  name = "${var.namespace}-app"
  min_size = "1"
  max_size = "2"
  health_check_grace_period = 300
  health_check_type = "EC2"
  launch_configuration = "${aws_launch_configuration.as_conf.id}"
}