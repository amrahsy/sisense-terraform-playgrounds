#!/bin/bash

################################################################################
# Install PIP
################################################################################
sudo apt-get update --yes
sudo apt-get install --yes python3-pip unzip jq curl && sudo pip3 install yq

################################################################################
# Install AZ CLI
################################################################################
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

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
git clone https://github.com/amrahsy/sisense-terraform-playgrounds.git && sudo chown -R vagrant:vagrant sisense-terraform-playgrounds
