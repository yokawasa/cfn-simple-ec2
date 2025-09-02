# cfn-simple-ec2

Cloudformation template for a simple Amazon EC2 environment  for PoC.

This template sets up a simple EC2 instance with basic configurations, allowing HTTP and SSH access while automating the installation of Docker.

## About this Cfn template

This CloudFormation template performs the following tasks:

1. **Parameter Definitions**

   - **IPv4CIDR**: Specifies the CIDR prefix for the VPC subnet, such as `10.1`, with a default subnet mask of `/16`.
   - **KeyPairName**: Specifies the name of an existing EC2 KeyPair to enable SSH access to the instance.
   - **AllowedIP**: Specifies the IP address range (in CIDR format) allowed to access the EC2 instance, with a default value of `0.0.0.0/0` (open to all).
2. **VPC Stack Creation**

   - Uses an external template to create a VPC with subnets and security groups.
3. **Security Group Configuration**

   - Allows **HTTP access (port 80)** and **SSH access (port 22)** from the specified IP range.
4. **IAM Role and Instance Profile Creation**

   - Creates an IAM role and instance profile to allow the EC2 instance to assume the role and access AWS services.
5. **EC2 Instance Creation**

   - Launches an EC2 instance with the following configurations:
     - **Amazon Linux 2023 AMI**.
     - **t4g.micro instance type** (a cost-effective small instance, Graviton2, arm64 arch).
     - **50GB gp3 volume** for storage.
     - Installs Docker and Docker Compose, and configures Docker to start on boot.
     - Associates the instance with the created security group and subnet.
6. **Outputs**

   - Provides the public URL for HTTP access to the EC2 instance.
   - Outputs the SSH command to connect to the instance using the specified KeyPair.

## How to deploy an EC2 environment using Cloudformation

(1) Create KeyPair

```sh
aws ec2 create-key-pair --key-name MyEC2KeyPair --query 'KeyMaterial' --output text > MyEC2KeyPair.pem

chmod 400 MyEC2KeyPair.pem
```

(2) Deploy an EC2 environment

```sh
aws cloudformation create-stack \
  --stack-name <stack-name> \
  --region <region> \ 
  --template-body file://ec2.yaml \
  --capabilities CAPABILITY_IAM \
   --parameters \
    ParameterKey=KeyPairName,ParameterValue=<keypair-name>
```

replace `<stack-name>`, `<region>`, and `<keypair-name>` with your own values like this:

- stack-name: simple-ec2
- region: ap-northeast-1
- keypair-name: MyEC2KeyPair

## Quick test

SSH login to the EC2 instance

```sh
ssh -i yokawasa-aws-ssh.pem ec2-user@<Public-IP-Address>
```

Spin up an API server (exposing 80 port as 80)

```sh
# linux/arm64 arch
docker run -p 80:80 suika/httpbin

# linux/amd64 arch
# docker run -p 80:80 kennethreitz/httpbin
```

Test access

```
curl http:<Public-IP-Address>/get

{
  "args": {}, 
  "headers": {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7", 
    "Accept-Encoding": "gzip, deflate", 
    "Accept-Language": "ja,en;q=0.9,en-US;q=0.8", 
    "Connection": "close", 
    "Host": "*******", 
    "Upgrade-Insecure-Requests": "1", 
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36"
  }, 
  "origin": "*******", 
  "url": "http://*******/get"
}
```
