
# using default vpc configs

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

resource "aws_db_subnet_group" "example" {
  name       = "${var.name}"
  subnet_ids = ["${data.aws_subnet_ids.all.ids}"]

  tags {
    Name = "${var.name}"
  }
}

# Creating security groups

resource "aws_security_group" "db_instance" {
  name   = "${var.name}"
  vpc_id = "${data.aws_vpc.default.id}"

}

resource "aws_security_group_rule" "allow_db_access" {
  type              = "ingress"
  from_port         = "${var.port}"
  to_port           = "${var.port}"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.db_instance.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

Creating aws dc instance

resource "aws_db_instance" "mysql" {
  identifier              = "${var.name}"
  engine                  = "${var.engine_name}"
  engine_version          = "${var.engine_version}"
  port                    = "${var.port}"
  name                    = "${var.database_name}"
  username                = "${var.username}"
  password                = "${var.password}"
  instance_class          = "db.t2.micro"
  allocated_storage       = "${var.allocated_storage}"
  skip_final_snapshot     = true
  db_subnet_group_name    = "${aws_db_subnet_group.example.id}"
  vpc_security_group_ids  = ["${aws_security_group.db_instance.id}"]
  publicly_accessible     = true
  

  tags {
    Name = "${var.name}"
  }
}