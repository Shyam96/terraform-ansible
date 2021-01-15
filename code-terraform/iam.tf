#******* IAM role ********

resource "aws_iam_role" "instance_role" {
  name = "${var.namespace}-instance-role"
  path = "/${var.namespace}/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


data "template_file" "test-instance-policy" {
  template = "${file("${path.module}/test-instance-policy.json")}"
  vars {
    aws_account = "${data.aws_caller_identity.current.account_id}"
    s3_config_bucket = "${aws_s3_bucket.test_config_bucket.id}"
    region = "${data.aws_region.current.name}"
    namespace = "${var.namespace}"
  }
}

resource "aws_iam_policy" "policy" {
  name = "${var.namespace}-instance-policy"
  path = "/${var.namespace}/"
  description = "Policy for ${var.namespace} instances"
  policy = "${data.template_file.test-instance-policy.rendered}"
  lifecycle {
    ignore_changes = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "instance-policy-attach" {
  role = "${aws_iam_role.instance_role.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}