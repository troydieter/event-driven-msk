# Resources

resource "aws_security_group" "data_platform" {
  name_prefix = "${var.cluster_name}-${random_id.rando.hex}"
  vpc_id      = module.vpc.vpc_id
  description = "${var.cluster_name}-${var.environment}-${random_id.rando.hex}-sg"
}

resource "aws_security_group_rule" "msk-plain" {
  description       = "${var.cluster_name}-${var.environment}-${random_id.rando.hex}-msk-plain"
  from_port         = 9092
  to_port           = 9092
  protocol          = "tcp"
  security_group_id = aws_security_group.data_platform.id
  type              = "ingress"
  cidr_blocks = var.cidr_blocks
}

resource "aws_security_group_rule" "msk-tls" {
  description       = "${var.cluster_name}-${var.environment}-${random_id.rando.hex}-msk-tls"
  from_port         = 9094
  to_port           = 9094
  protocol          = "tcp"
  security_group_id = aws_security_group.data_platform.id
  type              = "ingress"
  cidr_blocks = var.cidr_blocks
}

resource "aws_security_group_rule" "msk-iam" {
  description       = "${var.cluster_name}-${var.environment}-${random_id.rando.hex}-msk-iam"
  from_port         = 9098
  to_port           = 9098
  protocol          = "tcp"
  security_group_id = aws_security_group.data_platform.id
  type              = "ingress"
  cidr_blocks = var.cidr_blocks
}

resource "aws_security_group_rule" "zookeeper-plain" {
  description       = "${var.cluster_name}-${var.environment}-${random_id.rando.hex}-zookeeper-plain"
  from_port         = 2181
  to_port           = 2181
  protocol          = "tcp"
  security_group_id = aws_security_group.data_platform.id
  type              = "ingress"
  cidr_blocks = var.cidr_blocks
}

resource "aws_security_group_rule" "zookeeper-tls" {
  description       = "${var.cluster_name}-${var.environment}-${random_id.rando.hex}-zookeeper-tls"
  from_port         = 2182
  to_port           = 2182
  protocol          = "tcp"
  security_group_id = aws_security_group.data_platform.id
  type              = "ingress"
  cidr_blocks = var.cidr_blocks
}

resource "aws_security_group_rule" "jmx-exporter" {
  count = var.prometheus_jmx_exporter ? 1 : 0

  from_port         = 11001
  to_port           = 11001
  protocol          = "tcp"
  security_group_id = aws_security_group.data_platform.id
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "node_exporter" {
  count = var.prometheus_node_exporter ? 1 : 0

  from_port         = 11002
  to_port           = 11002
  protocol          = "tcp"
  security_group_id = aws_security_group.data_platform.id
  type              = "ingress"
  self              = true
}

resource "aws_msk_configuration" "data_platform" {
  kafka_versions    = [var.kafka_version]
  name              = "${var.cluster_name}-${var.environment}-${random_id.rando.hex}"
  description       = "MSK platform deployment for ${lower("${var.aws-profile}")}-event-driven-msk-${random_id.rando.hex}"
  server_properties = <<PROPERTIES
auto.create.topics.enable = true
delete.topic.enable = true
PROPERTIES

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_msk_cluster" "data_platform" {
  depends_on = [
    aws_msk_configuration.data_platform,
    module.vpc
  ]

  cluster_name           = "${var.cluster_name}-${var.environment}-${random_id.rando.hex}"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_nodes
  enhanced_monitoring    = var.enhanced_monitoring

  broker_node_group_info {
    client_subnets  = module.vpc.public_subnets
    ebs_volume_size = var.volume_size
    instance_type   = var.instance_type
    security_groups = concat(aws_security_group.data_platform.*.id, var.extra_security_groups)
  }

  configuration_info {
    arn      = aws_msk_configuration.data_platform.arn
    revision = aws_msk_configuration.data_platform.latest_revision
  }

  client_authentication {
    sasl {
      iam   = true
      scram = true
    }
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = var.encryption_at_rest_kms_key_arn

    encryption_in_transit {
      client_broker = var.encryption_in_transit_client_broker
      in_cluster    = var.encryption_in_transit_in_cluster
    }
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = var.prometheus_jmx_exporter
      }
      node_exporter {
        enabled_in_broker = var.prometheus_node_exporter
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk-cw-loggroup.name
      }
      s3 {
        enabled = true
        bucket  = module.s3_bucket.s3_bucket_id
        prefix  = "${var.cluster_name}-${var.environment}-${random_id.rando.hex}"
      }
    }

  }

  tags = local.common-tags
}