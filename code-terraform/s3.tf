resource "aws_s3_bucket" "test_config_bucket" {
  bucket = "${var.namespace}-config"
  acl    = "private"
  force_destroy = "false"
  tags{
    Name = "${var.namespace}-config"
  }
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle {
    ignore_changes = ["*"]
  }
}

resource "aws_s3_bucket_policy" "b" {
  bucket = "${aws_s3_bucket.test_config_bucket.id}"
  policy = "${data.template_file.bucket_policy.rendered}"
}

data "template_file" "bucket_policy" {
  template = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "allow access",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::$${aws_account}:root"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::$${namespace}-config/*",
                "arn:aws:s3:::$${namespace}-config"
            ]
        }
    ]
}
POLICY

  vars {
    namespace = "${var.namespace}"
    aws_account = "${data.aws_caller_identity.current.account_id}"
  }
}
