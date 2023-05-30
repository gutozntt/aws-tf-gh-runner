#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

REGION=${region}
LABEL=${label}
ARCH=${arch}

yum update -y

# install docker
amazon-linux-extras install -y docker
service docker start
chkconfig docker on
usermod -a -G docker ec2-user

# install git
yum install git make libicu60 jq -y

# install github runner application
sudo -u ec2-user mkdir /home/ec2-user/actions-runner
sudo -u ec2-user curl -o /home/ec2-user/actions-runner/actions-runner-linux-$${ARCH}-2.304.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.304.0/actions-runner-linux-$${ARCH}-2.304.0.tar.gz
sudo -u ec2-user tar xzf /home/ec2-user/actions-runner/actions-runner-linux-$${ARCH}-2.304.0.tar.gz -C /home/ec2-user/actions-runner

RUNNER_NAME="aws-runner-$${LABEL}"
RUNNER_WORKDIR=$${RUNNER_WORKDIR:-_work}

GITHUB_ACCESS_TOKEN=$(aws ssm get-parameter --name github-pat --region $${REGION} --with-decryption --output text --query Parameter.Value)
GITHUB_ACTIONS_RUNNER_CONTEXT=$(aws ssm get-parameter --name github-runner-context --region $${REGION} --with-decryption --output text --query Parameter.Value)

if [[ -z "$${GITHUB_ACCESS_TOKEN}" || -z "$${GITHUB_ACTIONS_RUNNER_CONTEXT}" ]]; then
  echo 'One of the mandatory parameters is missing. Quit!'
  exit 1
else
  AUTH_HEADER="Authorization: token $${GITHUB_ACCESS_TOKEN}"
  USERNAME=$(cut -d/ -f4 <<< $${GITHUB_ACTIONS_RUNNER_CONTEXT})
  REPOSITORY=$(cut -d/ -f5 <<< $${GITHUB_ACTIONS_RUNNER_CONTEXT})

  if [[ -z "$${REPOSITORY}" ]]; then 
    TOKEN_REGISTRATION_URL="https://api.github.com/orgs/$${USERNAME}/actions/runners/registration-token"
  else
    TOKEN_REGISTRATION_URL="https://api.github.com/repos/$${USERNAME}/$${REPOSITORY}/actions/runners/registration-token"
  fi
    
  RUNNER_TOKEN="$(curl -XPOST -fsSL \
    -H "Accept: application/vnd.github.v3+json" \
    -H "$${AUTH_HEADER}" \
    "$${TOKEN_REGISTRATION_URL}" \
    | jq -r '.token')"
fi

sudo -u ec2-user bash -c "cd /home/ec2-user/actions-runner/;./config.sh --url $${GITHUB_ACTIONS_RUNNER_CONTEXT} --token $${RUNNER_TOKEN} --name $${RUNNER_NAME} --work $${RUNNER_WORKDIR} --labels $${LABEL} --runasservice"
sudo -u ec2-user bash -c "cd /home/ec2-user/actions-runner/;./run.sh"