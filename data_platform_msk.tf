# Locals
locals {
  server_properties = join("\n", [for k, v in var.server_properties : format("%s = %s", k, v)])
  enable_logs       = var.s3_logs_bucket != "" || var.cloudwatch_logs_group != "" || var.firehose_logs_delivery_stream != "" ? ["true"] : []
}

# Vars
variable "cluster_name" {
  description = "Name of the MSK cluster."
  type        = string
  default     = "data_platform"
}

variable "kafka_version" {
  description = "Specify the desired Kafka software version."
  type        = string
  default     = "2.8.1"
}

variable "number_of_nodes" {
  description = "The desired total number of broker nodes in the kafka cluster. It must be a multiple of the number of specified client subnets."
  type        = number
  default     = 3
}

variable "client_subnets" {
  description = "A list of subnets to connect to in client VPC"
  type        = list(string)
  default     = ["subnet-07350c44836266baf", "subnet-0c86b986978390648", "subnet-03e97e0882eae5d8c"]
}

variable "volume_size" {
  description = "The size in GiB of the EBS volume for the data drive on each broker node."
  type        = number
  default     = 100
}

variable "instance_type" {
  description = "Specify the instance type to use for the kafka brokers. e.g. kafka.m5.large."
  type        = string
  default     = "kafka.t3.small"
}

variable "extra_security_groups" {
  description = "A list of extra security groups to associate with the elastic network interfaces to control who can communicate with the cluster."
  type        = list(string)
  default     = []
}

variable "enhanced_monitoring" {
  description = "Specify the desired enhanced MSK CloudWatch monitoring level to one of three monitoring levels: DEFAULT, PER_BROKER, PER_TOPIC_PER_BROKER or PER_TOPIC_PER_PARTITION. See [Monitoring Amazon MSK with Amazon CloudWatch](https://docs.aws.amazon.com/msk/latest/developerguide/monitoring.html)."
  type        = string
  default     = "PER_TOPIC_PER_BROKER"
}

variable "prometheus_jmx_exporter" {
  description = "Indicates whether you want to enable or disable the JMX Exporter."
  type        = bool
  default     = false
}

variable "prometheus_node_exporter" {
  description = "Indicates whether you want to enable or disable the Node Exporter."
  type        = bool
  default     = false
}

variable "server_properties" {
  description = "A map of the contents of the server.properties file. Supported properties are documented in the [MSK Developer Guide](https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html)."
  type        = map(string)
  default     = {}
}

variable "encryption_at_rest_kms_key_arn" {
  description = "You may specify a KMS key short ID or ARN (it will always output an ARN) to use for encrypting your data at rest. If no key is specified, an AWS managed KMS ('aws/msk' managed service) key will be used for encrypting the data at rest."
  type        = string
  default     = ""
}

variable "encryption_in_transit_client_broker" {
  description = "Encryption setting for data in transit between clients and brokers. Valid values: TLS, TLS_PLAINTEXT, and PLAINTEXT. Default value is TLS_PLAINTEXT."
  type        = string
  default     = "TLS_PLAINTEXT"
}

variable "encryption_in_transit_in_cluster" {
  description = "Whether data communication among broker nodes is encrypted. Default value: true."
  type        = bool
  default     = true
}

variable "s3_logs_bucket" {
  description = "Name of the S3 bucket to deliver logs to."
  type        = string
  default     = ""
}

variable "s3_logs_prefix" {
  description = "Prefix to append to the folder name."
  type        = string
  default     = ""
}

variable "cloudwatch_logs_group" {
  description = "Name of the Cloudwatch Log Group to deliver logs to."
  type        = string
  default     = ""
}

variable "firehose_logs_delivery_stream" {
  description = "Name of the Kinesis Data Firehose delivery stream to deliver logs to."
  type        = string
  default     = ""
}

# Data

data "aws_subnet" "data_platform_subnets" {
  id = var.client_subnets[0]
}

# Resources

resource "aws_security_group" "data_platform" {
  name_prefix = "${var.cluster_name}-${random_id.rando.hex}"
  vpc_id      = data.aws_subnet.data_platform_subnets.vpc_id
}

resource "aws_security_group_rule" "msk-plain" {
  from_port         = 9092
  to_port           = 9092
  protocol          = "tcp"
  security_group_id = aws_security_group.data_platform.id
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "msk-tls" {
  from_port         = 9094
  to_port           = 9094
  protocol          = "tcp"
  security_group_id = aws_security_group.data_platform.id
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "zookeeper-plain" {
  from_port         = 2181
  to_port           = 2181
  protocol          = "tcp"
  security_group_id = aws_security_group.data_platform.id
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "zookeeper-tls" {
  from_port         = 2182
  to_port           = 2182
  protocol          = "tcp"
  security_group_id = aws_security_group.data_platform.id
  type              = "ingress"
  self              = true
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
  name              = "data_platform_config-${var.environment}"
  server_properties = local.server_properties

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_msk_cluster" "data_platform" {
  depends_on = [aws_msk_configuration.data_platform]

  cluster_name           = var.cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_nodes
  enhanced_monitoring    = var.enhanced_monitoring

  broker_node_group_info {
    client_subnets  = var.client_subnets
    ebs_volume_size = var.volume_size
    instance_type   = var.instance_type
    security_groups = concat(aws_security_group.data_platform.*.id, var.extra_security_groups)
  }

  configuration_info {
    arn      = aws_msk_configuration.data_platform.arn
    revision = aws_msk_configuration.data_platform.latest_revision
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

  dynamic "logging_info" {
    for_each = local.enable_logs
    content {
      broker_logs {
        dynamic "firehose" {
          for_each = var.firehose_logs_delivery_stream != "" ? ["true"] : []
          content {
            enabled         = true
            delivery_stream = var.firehose_logs_delivery_stream
          }
        }
        dynamic "cloudwatch_logs" {
          for_each = var.cloudwatch_logs_group != "" ? ["true"] : []
          content {
            enabled   = true
            log_group = var.cloudwatch_logs_group
          }
        }
        dynamic "s3" {
          for_each = var.s3_logs_bucket != "" ? ["true"] : []
          content {
            enabled = true
            bucket  = var.s3_logs_bucket
            prefix  = var.s3_logs_prefix
          }
        }
      }
    }
  }

  tags = {
    "project"     = "${lower("${var.aws-profile}")}-event-driven-msk"
    "environment" = var.environment
    "id"          = random_id.rando.hex
  }
}