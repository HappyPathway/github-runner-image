#!/bin/bash -m
set -e

echo "Setting PATH to include /actions-runner"
export PATH="$PATH:/home/actions"

echo "Generating Random Suffix..."
suffix=$(cat /proc/sys/kernel/random/uuid | awk -F'-' '{ print $1 }')

echo "Generating RUNNER_NAME_FULL from NAMESPACE and HOSTNAME"
RUNNER_NAME_FULL="${NAMESPACE}-${HOSTNAME}-${suffix}"

# Cut the name if it is more than 64 characters
echo "Trimming RUNNER_NAME_FULL to 64 characters"
RUNNER_NAME=${RUNNER_NAME_FULL:0:64}

echo "Runner Name:: ${RUNNER_NAME}"
echo "Fetching ACCESS_TOKEN from AWS Secrets Manager"
ACCESS_TOKEN=$(aws secretsmanager get-secret-value --secret-id ${ACCESS_TOKEN_SECRET_PATH} --query SecretString --output text)

if [ -n "${CERTS_PATH}" ]; then
  echo "Setting up certificates"
  echo "creating /usr/local/share/ca-certificates"
  sudo mkdir -p /usr/local/share/ca-certificates
  echo "opying file from s3"
  aws s3 cp s3://${CERTS_PATH} /tmp/local-ca.crt
  echo "moving file yo ca-cert directory"
  sudo mv /tmp/local-ca.crt /usr/local/share/ca-certificates/local-ca.crt
  echo "updating ca certs"
  sudo update-ca-certificates
fi

# Support for setup-python
echo "Setting AGENT_TOOLSDIRECTORY to /opt/hostedtoolscache"
AGENT_TOOLSDIRECTORY=/opt/hostedtoolscache

echo NODE_TLS_REJECT_UNAUTHORIZED=0 >> /home/actions/.env
echo LANG=en_US.UTF-8 >> /home/actions/.env

echo "Changing directory to /actions-runner"
cd /home/actions

echo "Building config command"
command="./config.sh --unattended --url ${REPO_URL} --token ${ACCESS_TOKEN} --name ${RUNNER_NAME} "

# Add runner group if non-empty
if [ -n "${RUNNER_GROUP}" ]; then
  echo "Adding RUNNER_GROUP to config command"
  command="${command} --runnergroup ${RUNNER_GROUP}"
fi

echo "Adding labels, disableupdate, work directory, and replace options to config command"
command="${command} --labels ${RUNNER_LABELS} --disableupdate --work /actions-runner/_work --replace"

echo "Configuring GitHub runner with token..."
eval ${command}

echo "GitHub runner config with token complete."

echo "Starting GitHub runner"
env -u ACCESS_TOKEN ./run.sh
