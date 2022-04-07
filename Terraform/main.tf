terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}

resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr

    tags = {
    Name: "${var.env}-vpc"
    project: var.project_tag
    }
}

resource "aws_subnet" "subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.sub_cidr
    availability_zone = var.az

    tags = {
    Name: "${var.env}-subnet"
    project: var.project_tag
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
    Name: "${var.env}-igw"
    project: var.project_tag
    }
}

resource "aws_default_route_table" "rtb" {
    default_route_table_id = aws_vpc.vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
    Name: "${var.env}-rtb"
    project: var.project_tag
    }
}

resource "aws_security_group" "sg" {
    vpc_id = aws_vpc.vpc.id
    name = "${var.env}-sg"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
        ingress {
        from_port = 8443
        to_port = 8443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
        ingress {
        from_port = 9443
        to_port = 9443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
        ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
        egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
    Name: "${var.env}-sg"
    project: var.project_tag
    }
}

/*
Need to figure out a better way to do this as it currently deletes the key every single time.
Causes a lot of needless work re-importing the key to ssh in.

resource "tls_private_key" "redis-key" {
    algorithm = "RSA"
    rsa_bits = 4096
}


resource aws_key_pair "aws-redis-key" {
    key_name = "redis_key"
    public_key = tls_private_key.redis-key.public_key_openssh
    provisioner "local-exec" {
        command = "echo '${tls_private_key.redis-key.private_key_pem}' > ../Keys/redis.pem"
    }
}
*/

resource "aws_instance" "server1" {
    ami = var.ami_id
    instance_type = var.instance_type

    subnet_id = aws_subnet.subnet.id
    vpc_security_group_ids = [aws_security_group.sg.id]
    availability_zone = var.az
    associate_public_ip_address = true

    key_name = "redis_key"

    tags = {
        project: var.project_tag
        Name = "${var.env}-redis"
    }   

  //  provisioner "local_exec" {
  //      command = "ansible-playbook <path to playbook yaml>"
  //  }
}

resource "local_file" "redis_hosts" {
    content = templatefile("hosts.tftpl", {
        redis_ip    =   aws_instance.server1.public_ip
    })
    filename = "../Ansible/hosts"
}
