locals {
  enabled = module.this.enabled

  ssm_path_prefix        = format("/%s/%s", "aurora-postgres", data.aws_db_instance.this.db_cluster_identifier)
  ssm_cluster_key_prefix = format("%s/%s", local.ssm_path_prefix, "cluster")

  kafka_connection_properties = var.connection_type == "KAFKA" ? {
  } : {}
  jdbc_connection_properties = var.connection_type == "JDBC" ? {
    JDBC_CONNECTION_URL = "jdbc:${var.jdbc_database_type}://${data.aws_db_instance.this.endpoint}/${var.database_name}",
    USERNAME            = data.aws_ssm_parameter.username.value,
    PASSWORD            = data.aws_ssm_parameter.password.value
  } : {}
  network_connection_properties = var.connection_type == "NETWORK" ? {
  } : {}
  mongodb_connection_properties = var.connection_type == "MONGODB" ? {
  } : {}

  connection_properties = merge(
    local.jdbc_connection_properties,
    local.kafka_connection_properties,
    local.network_connection_properties,
    local.mongodb_connection_properties,
  )
  physical_connection_requirements = {
    availability_zone      = data.aws_db_instance.this.availability_zone
    security_group_id_list = data.aws_db_instance.this.vpc_security_groups,
    subnet_id              = tolist(data.aws_subnet_ids.this.ids)[0]
  }
}

data "aws_db_instance" "this" {
  db_instance_identifier = var.database_instance
}

data "aws_db_subnet_group" "this" {
  name = data.aws_db_instance.this.db_subnet_group
}

data "aws_subnet_ids" "this" {
  vpc_id = var.vpc_id
  filter {
    name   = "availability-zone"
    values = [data.aws_db_instance.this.availability_zone]
  }

  filter {
    name   = "subnet-id"
    values = tolist(data.aws_db_subnet_group.this.subnet_ids)
  }
}

data "aws_ssm_parameter" "username" {
  name = "${local.ssm_cluster_key_prefix}/admin/db_username"
}

data "aws_ssm_parameter" "password" {
  name = "${local.ssm_cluster_key_prefix}/admin/db_password"
}

resource "aws_glue_connection" "this" {
  count = local.enabled ? 1 : 0
  name  = module.this.id

  connection_type       = var.connection_type
  connection_properties = local.connection_properties

  physical_connection_requirements {
    availability_zone      = local.physical_connection_requirements.availability_zone
    security_group_id_list = local.physical_connection_requirements.security_group_id_list
    subnet_id              = local.physical_connection_requirements.subnet_id
  }

  tags = module.this.tags
}