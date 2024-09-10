#!/usr/bin/python
import os
import subprocess

# Set environment variables
os.environ['PATH'] = os.environ['PATH'] + ':/actions-runner'
NAMESPACE = os.getenv('NAMESPACE')
HOSTNAME = os.getenv('HOSTNAME')
RUNNER_NAME_FULL = f"{NAMESPACE}-{HOSTNAME}"

# Cut the name if it is more than 64 characters
RUNNER_NAME = RUNNER_NAME_FULL[:64]

# Support for setup-python
os.environ['AGENT_TOOLSDIRECTORY'] = '/opt/hostedtoolscache'

# Change directory to /actions-runner
os.chdir('/actions-runner')

cmd = [
    './config.sh',
    '--unattended',
    '--url', os.getenv('REPO_URL'),
    '--token', os.getenv('ACCESS_TOKEN'),
    '--name', RUNNER_NAME,
    '--labels', os.getenv('RUNNER_LABELS'),
    '--work', '/actions-runner/_work',
    '--disableupdate',
    '--replace',
    '--ephemeral'
]
if os.getenv('RUNNER_GROUP'):
    cmd.extend(['--runner_group', os.getenv('RUNNER_GROUP')])

# Execute the config.sh script
subprocess.run(cmd)

print("github runner config with token complete.")

# Execute the run.sh script with ACCESS_TOKEN removed from the environment
env = os.environ.copy()
os.environ.update({
      "NODE_TLS_REJECT_UNAUTHORIZED": 0,
      "LANG":  "en_US.UTF-8"
})
env.pop('ACCESS_TOKEN', None)
subprocess.run(['./run.sh'], env=env)
