locals {
  ami_id = var.runner_architecture == "x64" ? data.aws_ssm_parameter.amd_ami.value : data.aws_ssm_parameter.arm64_ami.value
}

module "runner" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.1.2"

  name = var.runner_name

  ami                    = var.ami_id == null ? local.ami_id : var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  monitoring             = var.monitoring
  iam_instance_profile   = var.iam_instance_profile == null ? aws_iam_instance_profile.runner_instance_profile.name : var.iam_instance_profile
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id              = var.subnet_id

  user_data_base64 = base64encode(templatefile("./user_data.sh", { region = var.region, label = var.label, arch = lower(var.runner_architecture) }))

  tags = {
    Name      = var.runner_name
    Terraform = "true"
  }
}

resource "aws_iam_instance_profile" "runner_instance_profile" {
  name  = "${var.runner_name}-${var.label}-role"
  role  = aws_iam_role.runner_role.name
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "runner_role" {
  name               = "${var.runner_name}-${var.label}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.runner_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.runner_role.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
}

data "aws_ssm_parameter" "amd_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-kernel-5.10-hvm-x86_64-gp2"
}

data "aws_ssm_parameter" "arm64_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-kernel-5.10-hvm-arm64-gp2"
}