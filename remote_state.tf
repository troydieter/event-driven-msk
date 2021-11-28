terraform {
  backend "s3" {
    bucket               = "troydieter.com-tfstate"
    key                  = "event-driven-msk.tfstate"
    workspace_key_prefix = "event-driven-msk-tfstate"
    region               = "us-east-1"
    dynamodb_table       = "td-tf-lockstate"
  }
}
