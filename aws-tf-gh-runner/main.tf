module "runner" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.1.2"

  name = var.runner_name

  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  monitoring             = var.monitoring
  iam_instance_profile   = var.iam_instance_profile
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id              = var.subnet_id

  user_data_base64 = base64encode(templatefile("./user_data.sh", { region = var.region, label = var.label, arch = lower(var.runner_architecture) }))

  tags = {
    Name      = var.runner_name
    Terraform = "true"
  }
}