resource "aws_launch_template" "external" {
  name_prefix            = "external-${local.environment_name}"
  description            = "EKS managed node group external launch template"
  update_default_version = true

  instance_type = var.sisense_node_config.instance_type
  key_name      = aws_key_pair.bastion_ssh_key_pair.key_name
  user_data     = filebase64("./scripts/sisense_s3_user_data")

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 150
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}