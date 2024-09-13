#!/bin/bash -m
export PATH="$PATH:/actions-runner"
RUNNER_NAME_FULL="${NAMESPACE}-${HOSTNAME}"

# Cut the name if it is more than 64 characters
RUNNER_NAME=${RUNNER_NAME_FULL:0:64}

ACCESS_TOKEN=$(aws secretsmanager get-secret-value --secret-id ${ACCESS_TOKEN_SECRET_PATH} --query SecretString --output text)

# Support for setup-python
AGENT_TOOLSDIRECTORY=/opt/hostedtoolscache
cd /actions-runner
command="./config.sh --unattended --url ${REPO_URL} --token ${ACCESS_TOKEN} --name ${RUNNER_NAME} "

# Add runner group if non-empty
if [ -n "${RUNNER_GROUP}" ]; then
  command="${command} --runnergroup ${RUNNER_GROUP}"
fi

command="${command} --labels ${RUNNER_LABELS} --disableupdate --work /actions-runner/_work --replace"
echo "Configuring github runner with token..."
eval ${command}

echo "github runner config with token complete."

env -u ACCESS_TOKEN ./run.sh
