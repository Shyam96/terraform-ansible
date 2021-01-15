#!/bin/sh
yum install java -y
echo "running playbook"
pip install ansible boto3
aws s3 cp s3://test-config/ansible/ansible-provision.tar.gz ansible-provision.tar.gz
mkdir -p /root/ansible/ && tar -xvzf ansible-provision.tar.gz -C /root/ansible/
/usr/local/bin/ansible-playbook /root/ansible/test.yml --connection=local