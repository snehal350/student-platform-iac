#!/usr/bin/env bash
# Prepares an Ubuntu 22.04 control node: swap, AWS CLI, Terraform, Ansible, SSH key, tfvars.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a

echo ">>> 1/6 Swap (1 GB RAM is tight for Terraform)"
if ! swapon --show | grep -q /swapfile; then
  [ -f /swapfile ] || sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 status=none
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile >/dev/null
  sudo swapon /swapfile
fi

echo ">>> 2/6 Base packages"
sudo apt-get update -y
sudo apt-get install -y curl unzip jq git python3 python3-pip python3-venv

echo ">>> 3/6 Shell settings"
if ! grep -q "# student-platform-iac" ~/.bashrc; then
  cat >> ~/.bashrc <<'EOT'
# student-platform-iac
export PATH=$HOME/bin:$HOME/.local/bin:$PATH
export TF_DATA_DIR=/tmp/tf-data
export AWS_DEFAULT_REGION=ap-south-1
[ -f ~/ansible-venv/bin/activate ] && source ~/ansible-venv/bin/activate
EOT
fi
export PATH=$HOME/bin:$HOME/.local/bin:$PATH
export AWS_DEFAULT_REGION=ap-south-1
mkdir -p ~/bin /tmp/tf-data

echo ">>> 4/6 AWS CLI + Terraform"
if ! command -v aws >/dev/null; then
  cd /tmp
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
  unzip -q awscliv2.zip
  sudo ./aws/install
  rm -rf aws awscliv2.zip
fi
if [ ! -x ~/bin/terraform ]; then
  cd /tmp
  TF_VER=1.9.8
  curl -fsSLO "https://releases.hashicorp.com/terraform/${TF_VER}/terraform_${TF_VER}_linux_amd64.zip"
  unzip -o "terraform_${TF_VER}_linux_amd64.zip" -d ~/bin
  rm -f "terraform_${TF_VER}_linux_amd64.zip"
fi

echo ">>> 5/6 Ansible (venv)"
if [ ! -f ~/ansible-venv/bin/activate ]; then
  python3 -m venv ~/ansible-venv
fi
source ~/ansible-venv/bin/activate
pip install --quiet --upgrade pip
pip install --quiet "ansible-core>=2.16,<2.17"

echo ">>> 6/6 SSH key + Terraform variables"
mkdir -p ~/.ssh
[ -f ~/.ssh/student-aws-key ] || ssh-keygen -t rsa -b 4096 -f ~/.ssh/student-aws-key -N "" -C "student@devops"
chmod 400 ~/.ssh/student-aws-key
chmod 644 ~/.ssh/student-aws-key.pub
MYIP=$(curl -s https://checkip.amazonaws.com | tr -d '[:space:]')
echo "ssh_allowed_cidr = \"${MYIP}/32\"" > "$ROOT/terraform/terraform.tfvars"

echo
echo "=============== VERSIONS ==============="
aws --version
terraform -version | head -1
ansible --version | head -1
echo "tfvars: $(cat "$ROOT/terraform/terraform.tfvars")"
echo "=============== AWS IDENTITY ==============="
aws sts get-caller-identity || echo "WARNING: no AWS credentials. Attach the IAM role to this instance (EC2 > Actions > Security > Modify IAM role)."
echo
echo "Setup finished. Now run:  source ~/.bashrc"
