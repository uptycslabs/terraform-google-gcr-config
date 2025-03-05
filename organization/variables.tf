/*
 * Copyright (c) 2023 Uptycs, Inc. All rights reserved
 */

variable uptycs_aws_account_id {
    description = "Aws account id of Uptycs - for federated identity"
    type = string
}

variable "uptycs_aws_instance_roles" {
  type        = list 
  description = "AWS role names of Uptycs - for identity binding"
  default     = ["Role_Allinone", "Role_PNode"]
}

variable integration_name {
    description = "ExternalId to be used for API authentication."
    type = string
}

variable "gcp_host_project_id" {
  type        = string
  description = "The GCP project ID where the service account and workload identity pool will be created"
}

variable "service_account_exists" {
  type        = bool
  description = "Set to true if service account already exists."
  default     = false
}

variable "service_account_name" {
  type        = string
  description = "The GCP service account name, If a service account with this name already exists, then be sure to set service_account_exists=true"
}

variable "gcr_integration" {
  type        = bool
  default     = false
  description = "Set to true to enable legacy GCR integration."
}

variable "org_id" {
  type        = string
  description = "The GCP organization ID where resources will be managed"
}
