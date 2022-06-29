#!/bin/bash

################################################################################
# Install PIP
################################################################################
sudo apt-get update --yes
sudo apt-get install --yes python3-pip unzip jq && sudo pip3 install yq

################################################################################
# Install AWS CLI
################################################################################
curl --silent --location "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
rm -fr awscliv2* aws*/

################################################################################
# Install EKSCTL CLI
################################################################################
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
source <(eksctl completion bash) 2>/dev/null

## If you're running the AWS CLI version 1.16.156 or later, then you don't need to install the authenticator. Instead, you can use the aws eks get-token command.

################################################################################
# Install Kubectl
################################################################################
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo rm kubectl

################################################################################
# Set up Terraform 
################################################################################
echo "Ensure that your system is up to date, and you have the gnupg, software-properties-common, and curl packages installed. You will use these packages to verify HashiCorp's GPG signature, and install HashiCorp's Debian package repository."
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl

echo "Add the HashiCorp GPG key."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

echo "Add the official HashiCorp Linux repository."
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

echo "Update to add the repository, and install the Terraform CLI."
sudo apt-get update && sudo apt-get install -y terraform

################################################################################
# Install HELM
################################################################################
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && chmod +x get_helm.sh && DESIRED_VERSION=v3.8.2 ./get_helm.sh

################################################################################
# Clone sisense-terraform-playgrounds Github repository
################################################################################
git clone https://github.com/amrahsy/sisense-terraform-playgrounds.git
