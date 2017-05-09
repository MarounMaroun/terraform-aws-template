provider "aws" {
  secret_key = "${var.secret_key}"
  access_key = "${var.access_key}"
  region = "${var.aws_region}"
}

# INSTANCE
resource "aws_instance" "web" {
  subnet_id = "${aws_subnet.main.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
  ami = "${var.aws_ami}"
  instance_type = "m1.small"
}

# EIP which is reachable from the internet
resource "aws_eip" "lb" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_eip_association" "eip_association" {
  instance_id   = "${aws_instance.web.id}"
  allocation_id = "${aws_eip.lb.id}"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/24"
}

resource "aws_security_group" "allow_all" {
  name = "Terraform SG"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

# a VPC component that allows communication between our VPC and the internet
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.0.0/24"
}

resource "aws_route" "internet_access" {
  route_table_id = "${aws_route_table.route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.gw.id}"
}

resource "aws_route_table_association" "public_association" {
    subnet_id = "${aws_subnet.main.id}"
    route_table_id = "${aws_route_table.route_table.id}"
}

resource "aws_route_table" "route_table" {
    vpc_id = "${aws_vpc.main.id}"
}
