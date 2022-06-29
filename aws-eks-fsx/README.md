# AWS-EKS-FSX Playground (WIP)

For better readability, [navigate to the HackMD note](https://hackmd.io/@yug/playground-aws-eks-fsx)

## Table of Contents
| Content                                |
| :--------                              |
| [Introduction](#Introduction-)         |
| [Requirements](#Requirements-)         |
| [Installation](#Installation-)         |
| [Access](#Access)                      |
| [Troubleshooting](#Troubleshooting-)   |
| [Configuration](#Configuration-)       |
| [Cleanup](#Cleanup-)                   |
| [Maintainers](#Maintainers)            |

### Introduction :man_in_tuxedo: 
---
Use this guide to deploy an EKS cluster along with the required infrastructure components (such as `VPC`, `Bastion node`, `Managed Node groups`, `Lustre FSX file-system` etc.)

### Requirements :spiral_note_pad: 
---
:::info
In this guide, the installation steps are executed from within a vagrant VM. If you do not prefer to set up the vagrant VM, you must install the required utilities before. 
:::
* [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli) - `~> v1.2.2`
* [Kubectl CLI](https://kubernetes.io/docs/tasks/tools/#kubectl)
* [HELM CLI](https://helm.sh/docs/intro/install/) - `v3.4.1 or later`
* (*Optional*) [Vagrant CLI](https://www.vagrantup.com/docs/installation) - `>= 2.2.17`
* (*Optional*) [VirtualBox](https://www.virtualbox.org/wiki/Downloads) - `>= 6.1.34`
* AWS
    * [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) - `v2`
    * [IAM user with programmitic aceess](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html) in your AWS account

### Installation :rocket: 
---

#### (Optional) Step 1 - Deploy the Vagrant VM
:::danger
Disable Zscaler and quit the Zscaler application to build the vagrant VM successfully
:::
* Clone this Github repository on your local machine 
```bash=
git clone https://github.com/amrahsy/sisense-terraform-playgrounds.git
```
* Navigate to the following directory
```bash=
cd sisense-terraform-playgrounds/aws-eks-fsx/scripts
```
The scripts folder contains the `Vagrantfile` along with the `vagrant_vm_utilities.sh` script to set up the vagrant VM with the required utilities

* From within the `scripts`directory, execute the following command
```bash=
vagrant up
```
If the installation is successful, you will see the following lines at the end of the output
:::success
terraform-playground: Verifying checksum... Done.  
terraform-playground: Preparing to install helm into /usr/local/bin  
terraform-playground: helm installed into /usr/local/bin/helm  
terraform-playground: Cloning into 'sisense-terraform-playgrounds'...  
:::

* SSH to the vagrant machine from within the scripts directory using the following command
```bash=
vagrant ssh
```

#### Step 2 - Create a Terraform Cloud account with one organization and no workspaces 
:::info
We will use a Terraform Cloud account for remote state management. This will prevent issues when managing terraform state locally. 
:::
* [Create an account](https://learn.hashicorp.com/tutorials/terraform/cloud-sign-up#create-an-account)
* [Create an organization](https://learn.hashicorp.com/tutorials/terraform/cloud-sign-up#create-an-organization)

#### Step 3 - Log in to Terraform Cloud from the CLI and create a credentials variable set using AWS IAM credentials
:::warning
If you are using the vagrant VM, the following steps must be executed inside the SSH session create via the **`vagrant ssh`** command
:::
* [Log in to Terraform Cloud from the CLI](https://learn.hashicorp.com/tutorials/terraform/cloud-login?cloud-get-started)
* [Create a Credentials Variable Set](https://learn.hashicorp.com/tutorials/terraform/cloud-create-variable-set?in=terraform/cloud-get-started)

#### Step 4 - Configure the AWS CLI
Use the values of `AWS_ACCESS_KEY_ID` & `AWS_SECRET_ACCESS_KEY` to configure the AWS CLI with the following command
```bash=
aws configure
```

#### Step 5 - Execute terraform CLI commands to create the playground
* Navigate to the `aws-eks-fsx` directory
```bash=
cd sisense-terraform-playgrounds/aws-eks-fsx/
```
* Edit the terraform block in the `versions.tf` file to specify the Terraform Cloud `organization` name and a `workspace` name. For example
```json=
terraform {
  cloud {
    organization = "<CHANGE-ME>" <---

    workspaces {
      name = "<CHANGE-ME>" <---
    }
...
```
* Initialize providers
```bash=
terraform init
```
* Create resources
:::danger
If you are deploying multiple playgrounds using these instructions, make sure to update the workspace name in **`versions.tf`** before each run (`terraform apply`) to isolated different resources in their respective workspaces.

:::
```bash=
terraform apply -var region=<region-name>
```
When prompted to apply, type `yes`. This operation can take about ~50 mins to complete.

### Access
---
Following instructions can be used to access the terraform deployed resources either via the vagrant VM or the bastion node created as part of the installation

**From Vagrant VM**
* `kubectl` access to the EKS cluster from the vagrant VM
```bash=
terraform output -raw cluster_id
aws eks update-kubeconfig --name <value-cluster_id>
kubectl get nodes
```

**From Bastion node**
* SSH access - `bastion` node
```bash=
terraform output -raw bastion_public_dns
terraform output -raw bastion_private_key_openssh > <cluster_id>-key.pem && chmod 400 <cluster_id>-key.pem
ssh -i <cluster_id>-key.pem ec2-user@<value-bastion_public_dns>
```
* `kubectl` access from the `bastion` node
```bash=
aws configure
aws eks update-kubeconfig --name <value-cluster_id>
```
* SSH access - `EKS managed groups nodes` from the `bastion` node
```bash=
# Copy private key of bastion to the bastion node
terraform output -raw bastion_public_dns
scp -i <cluster_id>-key.pem <cluster_id>-key.pem ec2-user@<value-bastion_public_dns>:/home/ec2-user

# SSH to bastion node
ssh -i <cluster_id>-key.pem ec2-user@<value-bastion_public_dns>
kubectl get nodes
ssh -i <cluster_id>-key.pem ec2-user@<node-name>
```

:::warning
Sisense installation must be executed from the bastion node because the nodes in the EKS managed node groups are deployed in private subnets
:::

### Maintainers
---
Current maintainers:
- [Yugam Sharma](https://github.com/amrahsy) 