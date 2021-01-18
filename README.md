Task : Terraform with any Configuration Management tool integrated.

1. Create a Ansible tar-ball file of test.yml file which is in ansible directory in repo and upload the ansible tar to s3 bucket
    tar -czvf ansible-provision.tar.gz test.yml
2. Create the s3 bucket resource using terraform with target & upload the deployable .war file to s3
3. Run the terraform in code-terraform directory, all the resopurces will be created.
4. EC2 instnace will launch by using Autoscaling group, then it will run userdata next ansible tarball file will download.
5. Userdata will execute the Ansible yml in server - all the tasks in yml will be performed inside the server.
6. RDS - mySQL db will be created and application will connect to DB with endpoint. We have update the AWS parameter store for application properties & credentails
