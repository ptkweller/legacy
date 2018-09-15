provider "aws" {
  region = "${var.region}"
  access_key = "${var.accessKey}"
  secret_key = "${var.secretKey}"
  version = "~> 1.32"
} 

resource "aws_vpc" "Legacy_VPC" {
  cidr_block = "${var.vpcCIDRblock}"
  instance_tenancy = "${var.instanceTenancy}" 
  enable_dns_support = "${var.dnsSupport}" 
  enable_dns_hostnames = "${var.dnsHostNames}"
  tags {
    Name = "Legacy VPC"
  }
} 

resource "aws_subnet" "Legacy_VPC_Subnet" {
  vpc_id = "${aws_vpc.Legacy_VPC.id}"
  cidr_block = "${var.subnetCIDRblock}"
  map_public_ip_on_launch = "${var.mapPublicIP}" 
  availability_zone = "${var.availabilityZone}"
  tags = {
    Name = "Legacy VPC Subnet"
  }
} 

resource "aws_security_group" "Legacy_VPC_Security_Group" {
  vpc_id = "${aws_vpc.Legacy_VPC.id}"
  name = "Legacy VPC Security Group"
  description = "Legacy VPC Security Group"
  ingress {
    cidr_blocks = "${var.homeCIDRblockList}"  
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  ingress {
    cidr_blocks = "${var.ingressCIDRblock}"
    from_port = 17873
    to_port = 17873
	protocol = "tcp"
  }
  egress {
    cidr_blocks = "${var.egressCIDRblock}"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
  }
  tags = {
    Name = "Legacy VPC Security Group"
  }
} 

resource "aws_network_acl" "Legacy_VPC_Security_ACL" {
  vpc_id = "${aws_vpc.Legacy_VPC.id}"
  subnet_ids = [ "${aws_subnet.Legacy_VPC_Subnet.id}" ]
  # allow port 22
  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "${var.homeCIDRblock}" 
    from_port = 22
    to_port = 22
  }
  # allow ingress ephemeral ports 
  ingress {
    protocol = "tcp"
    rule_no = 200
    action  = "allow"
    cidr_block = "${var.destinationCIDRblock}"
    from_port = 1024
    to_port = 65535
  }
# allow egress ephemeral ports
  egress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "${var.destinationCIDRblock}"
    from_port = 0
    to_port = 65535
  }
  tags {
    Name = "Legacy VPC ACL"
  }
} 

resource "aws_internet_gateway" "Legacy_VPC_GW" {
  vpc_id = "${aws_vpc.Legacy_VPC.id}"
  tags {
    Name = "Legacy VPC Internet Gateway"
  }
} 

resource "aws_route_table" "Legacy_VPC_route_table" {
  vpc_id = "${aws_vpc.Legacy_VPC.id}"
  tags {
    Name = "Legacy VPC Route Table"
  }
} 

resource "aws_route" "Legacy_VPC_internet_access" {
  route_table_id = "${aws_route_table.Legacy_VPC_route_table.id}"
  destination_cidr_block = "${var.destinationCIDRblock}"
  gateway_id = "${aws_internet_gateway.Legacy_VPC_GW.id}"
} 

resource "aws_route_table_association" "Legacy_VPC_association" {
  subnet_id = "${aws_subnet.Legacy_VPC_Subnet.id}"
  route_table_id = "${aws_route_table.Legacy_VPC_route_table.id}"
}

resource "aws_instance" "legacy-webserver" {
  ami = "ami-0f0e3bc7c6215ebf8"
  instance_type = "t2.micro"

  vpc_security_group_ids = ["${aws_security_group.Legacy_VPC_Security_Group.id}"]

  subnet_id = "${aws_subnet.Legacy_VPC_Subnet.id}"
}
