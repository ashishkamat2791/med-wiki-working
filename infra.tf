  provider "aws" {
    region  = "${var.aws_region}"
    profile = "${var.aws_profile}"
  }
   
#-------------VPC-----------
  
  resource "aws_vpc" "media_vpc" {
    cidr_block           = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    enable_dns_support   = true
  
    tags {
      Name = "media_vpc"
    }
  }
  
  #internet gateway
  
  resource "aws_internet_gateway" "media_internet_gateway" {
    vpc_id = "${aws_vpc.media_vpc.id}"
  
    tags {
      Name = "media_igw"
    }
  }
  
  # Route tables
  
  resource "aws_route_table" "media_public_rt" {
    vpc_id = "${aws_vpc.media_vpc.id}"
  
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.media_internet_gateway.id}"
    }
  
    tags {
      Name = "media_public"
    }
  }
  
  resource "aws_default_route_table" "media_private_rt" {
    default_route_table_id = "${aws_vpc.media_vpc.default_route_table_id}"
  
    tags {
      Name = "media_private"
    }
  }
  
  resource "aws_subnet" "media_public1_subnet" {
    vpc_id                  = "${aws_vpc.media_vpc.id}"
    cidr_block              = "${var.cidrs["public1"]}"
    map_public_ip_on_launch = true
    availability_zone       = "${data.aws_availability_zones.available.names[0]}"
  
    tags {
      Name = "media_public1"
    }
  }
  
  resource "aws_subnet" "media_public2_subnet" {
    vpc_id                  = "${aws_vpc.media_vpc.id}"
    cidr_block              = "${var.cidrs["public2"]}"
    map_public_ip_on_launch = true
    availability_zone       = "${data.aws_availability_zones.available.names[1]}"
  
    tags {
      Name = "media_public2"
    }
  }
  
  resource "aws_subnet" "media_private1_subnet" {
    vpc_id                  = "${aws_vpc.media_vpc.id}"
    cidr_block              = "${var.cidrs["private1"]}"
    map_public_ip_on_launch = false
    availability_zone       = "${data.aws_availability_zones.available.names[0]}"
  
    tags {
      Name = "media_private1"
    }
  }
  
  resource "aws_subnet" "media_private2_subnet" {
    vpc_id                  = "${aws_vpc.media_vpc.id}"
    cidr_block              = "${var.cidrs["private2"]}"
    map_public_ip_on_launch = false
    availability_zone       = "${data.aws_availability_zones.available.names[1]}"
  
    tags {
      Name = "media_private2"
    }
  }
  
  
  
  resource "aws_subnet" "media_rds1_subnet" {
    vpc_id                  = "${aws_vpc.media_vpc.id}"
    cidr_block              = "${var.cidrs["rds1"]}"
    map_public_ip_on_launch = false
    availability_zone       = "${data.aws_availability_zones.available.names[0]}"
  
    tags {
      Name = "media_rds1"
    }
  }
  
  resource "aws_subnet" "media_rds2_subnet" {
    vpc_id                  = "${aws_vpc.media_vpc.id}"
    cidr_block              = "${var.cidrs["rds2"]}"
    map_public_ip_on_launch = false
    availability_zone       = "${data.aws_availability_zones.available.names[1]}"
  
    tags {
      Name = "media_rds2"
    }
  }
  
  resource "aws_subnet" "media_rds3_subnet" {
    vpc_id                  = "${aws_vpc.media_vpc.id}"
    cidr_block              = "${var.cidrs["rds3"]}"
    map_public_ip_on_launch = false
    availability_zone       = "${data.aws_availability_zones.available.names[2]}"
  
    tags {
      Name = "media_rds3"
    }
  }
  
  # Subnet Associations
  
  resource "aws_route_table_association" "media_public_assoc" {
    subnet_id      = "${aws_subnet.media_public1_subnet.id}"
    route_table_id = "${aws_route_table.media_public_rt.id}"
  }
  
  resource "aws_route_table_association" "media_public2_assoc" {
    subnet_id      = "${aws_subnet.media_public2_subnet.id}"
    route_table_id = "${aws_route_table.media_public_rt.id}"
  }
  
  resource "aws_route_table_association" "media_private1_assoc" {
    subnet_id      = "${aws_subnet.media_private1_subnet.id}"
    route_table_id = "${aws_default_route_table.media_private_rt.id}"
  }
  
  resource "aws_route_table_association" "media_private2_assoc" {
    subnet_id      = "${aws_subnet.media_private2_subnet.id}"
    route_table_id = "${aws_default_route_table.media_private_rt.id}"
  }
  
  resource "aws_db_subnet_group" "media_rds_subnetgroup" {
    name = "media_rds_subnetgroup"
  
    subnet_ids = ["${aws_subnet.media_rds1_subnet.id}",
      "${aws_subnet.media_rds2_subnet.id}",
      "${aws_subnet.media_rds3_subnet.id}",
    ]
  
    tags {
      Name = "media_rds_sng"
    }
  }
  
  #Security groups
  
  resource "aws_security_group" "media_dev_sg" {
    name        = "media_dev_sg"
    description = "Used for access to the dev instance"
    vpc_id      = "${aws_vpc.media_vpc.id}"
  
    #SSH
  
    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["${var.localip}"]
    }
  
    #HTTP
  
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["${var.localip}"]
    }
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  
  #Public Security group
  
  resource "aws_security_group" "media_public_sg" {
    name        = "media_public_sg"
    description = "Used for public and private instances for load balancer access"
    vpc_id      = "${aws_vpc.media_vpc.id}"
  
    #HTTP 
  
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    #Outbound internet access
  
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  
  #Private Security Group
  
  resource "aws_security_group" "media_private_sg" {
    name        = "media_private_sg"
    description = "Used for private instances"
    vpc_id      = "${aws_vpc.media_vpc.id}"
  
    # Access from other security groups
  
    ingress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  
  #RDS Security Group
  resource "aws_security_group" "media_rds_sg" {
    name        = "media_rds_sg"
    description = "Used for DB instances"
    vpc_id      = "${aws_vpc.media_vpc.id}"
  
    # SQL access from public/private security group
  
    ingress {
      from_port = 3306
      to_port   = 3306
      protocol  = "tcp"
  
      security_groups = ["${aws_security_group.media_dev_sg.id}",
        "${aws_security_group.media_public_sg.id}",
        "${aws_security_group.media_private_sg.id}",
      ]
    }
  }
  
  #S3 code bucket
  
  resource "random_id" "media_code_bucket" {
    byte_length = 2
  }
  
  resource "aws_s3_bucket" "code" {
    bucket        = "${var.domain_name}-${random_id.media_code_bucket.dec}"
    acl           = "private"
    force_destroy = true
  
    tags {
      Name = "code bucket"
    }
  }
  
  #---------compute-----------
  
  resource "aws_db_instance" "media_db" {
    allocated_storage      = 10
    engine                 = "mysql"
    engine_version         = "5.6.34"
    instance_class         = "${var.db_instance_class}"
    name                   = "${var.dbname}"
    username               = "${var.dbuser}"
    password               = "${var.dbpassword}"
    db_subnet_group_name   = "${aws_db_subnet_group.media_rds_subnetgroup.name}"
    vpc_security_group_ids = ["${aws_security_group.media_rds_sg.id}"]
    skip_final_snapshot    = true
  }
  
  #key pair
  
  resource "aws_key_pair" "media_auth" {
    key_name   = "${var.key_name}"
    public_key = "${file(var.public_key_path)}"
  }
  
  #dev server
  
  resource "aws_instance" "media_dev" {
    instance_type = "${var.dev_instance_type}"
    ami           = "${var.dev_ami}"
  
    tags {
      Name = "media_dev"
    }
  
    key_name               = "${aws_key_pair.media_auth.id}"
    vpc_security_group_ids = ["${aws_security_group.media_dev_sg.id}"]
    subnet_id              = "${aws_subnet.media_public1_subnet.id}"
  
    provisioner "local-exec" {
      command = <<EOD
  yum update -y && yum install ansible -y
  cat <<EOF > aws_hosts 
  [dev] 
  ${aws_instance.media_dev.public_ip} 
  EOD
    }
  
    provisioner "local-exec" {
      command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.media_dev.id} --profile thoughtorks && ansible-playbook -i aws_hosts mediawiki-docker.yml"
    }
  }
  
  #load balancer
  
  resource "aws_elb" "media_elb" {
    name = "${var.domain_name}-elb"
  
    subnets = ["${aws_subnet.media_public1_subnet.id}",
      "${aws_subnet.media_public2_subnet.id}",
    ]
  
    security_groups = ["${aws_security_group.media_public_sg.id}"]
  
    listener {
      instance_port     = 80
      instance_protocol = "http"
      lb_port           = 80
      lb_protocol       = "http"
    }
  
    health_check {
      healthy_threshold   = "${var.elb_healthy_threshold}"
      unhealthy_threshold = "${var.elb_unhealthy_threshold}"
      timeout             = "${var.elb_timeout}"
      target              = "TCP:80"
      interval            = "${var.elb_interval}"
    }
  
    cross_zone_load_balancing   = true
    idle_timeout                = 400
    connection_draining         = true
    connection_draining_timeout = 400
  
    tags {
      Name = "media_${var.domain_name}-elb"
    }
  }
  
  #AMI 
  
  resource "random_id" "golden_ami" {
    byte_length = 8
  }
  
  resource "aws_ami_from_instance" "media_golden" {
    name               = "media_ami-${random_id.golden_ami.b64}"
    source_instance_id = "${aws_instance.media_dev.id}"
  
  }
  
  #launch configuration
  
  resource "aws_launch_configuration" "media_lc" {
    name_prefix          = "media_lc-"
    image_id             = "${aws_ami_from_instance.media_golden.id}"
    instance_type        = "${var.lc_instance_type}"
    security_groups      = ["${aws_security_group.media_private_sg.id}"]
    key_name             = "${aws_key_pair.media_auth.id}"
  
    lifecycle {
      create_before_destroy = true
    }
  }
  
  #ASG 
  
  #resource "random_id" "rand_asg" {
  # byte_length = 8
  #}
  
  resource "aws_autoscaling_group" "media_asg" {
    name                      = "asg-${aws_launch_configuration.media_lc.id}"
    max_size                  = "${var.asg_max}"
    min_size                  = "${var.asg_min}"
    health_check_grace_period = "${var.asg_grace}"
    health_check_type         = "${var.asg_hct}"
    desired_capacity          = "${var.asg_cap}"
    force_delete              = true
    load_balancers            = ["${aws_elb.media_elb.id}"]
  
    vpc_zone_identifier = ["${aws_subnet.media_private1_subnet.id}",
      "${aws_subnet.media_private2_subnet.id}",
    ]
  
    launch_configuration = "${aws_launch_configuration.media_lc.name}"
  
    tag {
      key                 = "Name"
      value               = "media_asg-instance"
      propagate_at_launch = true
    }
  
    lifecycle {
      create_before_destroy = true
    }
  }
  
