set -e -x

STACK_NAME=simple-ec2
REGION=ap-northeast-1
KEYPAIR_NAME=yokawasa-aws-ssh

aws cloudformation create-stack \
  --stack-name ${STACK_NAME} \
  --region ${REGION} \
  --template-body file://ec2.yaml \
  --capabilities CAPABILITY_IAM \
  --parameters ParameterKey=KeyPairName,ParameterValue=${KEYPAIR_NAME}
