data "template_file" "userdata" {
  template = file("./userdata.tpl")
}

resource "aws_instance" "bastion_host" {
  ami           = var.ami_id
  instance_type = var.instance_type_BH
  key_name      = var.key_name
  subnet_id     = var.subnet_id[0]
  user_data     = data.template_file.userdata.rendered

  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  tags = {
    Name = "Bastion Host Rinshad"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg-rinshad"
  description = "Security group for Bastion Host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }
  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name = "Bastion SG Rinshad"
  }
}