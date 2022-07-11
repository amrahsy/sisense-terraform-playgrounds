################################################################################
# Resources: aws_security_group(Classic LB)
################################################################################
resource "aws_security_group" "sisense_api_gateway_access" {
  description = "Allow unencrypted traffic to Sisense API Gateway pods"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "To Port 80 From Anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.environment_name}-LB-SG"
  }
}

################################################################################
# Module ELB: Deploy a Classic LB (ELB) for use with Sisense after installation
# For environments where the K8s cluster was not created using a managed service 
# like EKS, you would configure the cluster_config.yaml file for installing Sisense
# cluster_config.yaml file does not contain 
################################################################################
module "elb" {
  source  = "terraform-aws-modules/elb/aws"
  version = "~> 3.0.1"

  name            = "${local.environment_name}-LB"
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.sisense_api_gateway_access.id]
  internal        = false

  listener = [
    {
      instance_port     = 30845
      instance_protocol = "TCP"
      lb_port           = 80
      lb_protocol       = "TCP"
    }
  ]

  health_check = {
    target              = "TCP:30845"
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 6
    timeout             = 5
  }
  // ELB attachments
  number_of_instances = 2
  instances           = ["${module.ec2-instance["app-qry-1"].id}", "${module.ec2-instance["app-qry-2"].id}"]
}