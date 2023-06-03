#!/usr/bin/env sh

# if arguements are less than 2 quit

RUNNER="$1"
MODE="$2"
if [ "$3" == "" ];then
  PORT="5000"
else
  PORT="$3"
fi

if [ "$RUNNER" == "localstack" ]; then
  pip install localstack
  localstack update all
  if ["$MODE" == "docker" ]; then
    docker run --rm -it -p $PORT:$PORT -p 4510-4559:4510-4559 localstack/localstack &
  else
    localstack start &
  fi
else if [ "$RUNNER" == "moto" ]; then
  if ["$MODE" == "docker" ]; then
    docker run --rm  -it -p $PORT:$PORT motoserver/moto:latest &
  else
    pip install 'moto[all]'
    moto_server -p$PORT &
  fi
fi

# Update profile/config
alias aws="aws --endpoint-url http://localhost:$PORT"

# Drop provider into current directory for Terraform
cat <<EOF > ./provider.tf
provider "aws" {
  access_key                  = "mock_access_key"
  region                      = "us-east-1"
  s3_force_path_style         = true
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localhost:$PORT"
    cloudformation = "http://localhost:$PORT"
    cloudwatch     = "http://localhost:$PORT"
    dynamodb       = "http://localhost:$PORT"
    es             = "http://localhost:$PORT"
    firehose       = "http://localhost:$PORT"
    iam            = "http://localhost:$PORT"
    kinesis        = "http://localhost:$PORT"
    lambda         = "http://localhost:$PORT"
    route53        = "http://localhost:$PORT"
    redshift       = "http://localhost:$PORT"
    s3             = "http://localhost:$PORT"
    secretsmanager = "http://localhost:$PORT"
    ses            = "http://localhost:$PORT"
    sns            = "http://localhost:$PORT"
    sqs            = "http://localhost:$PORT"
    ssm            = "http://localhost:$PORT"
    stepfunctions  = "http://localhost:$PORT"
    sts            = "http://localhost:$PORT"
  }
}
EOF
