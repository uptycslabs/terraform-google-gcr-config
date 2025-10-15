module "gcr-config-org" {
  source = "../../organization"
  
  uptycs_aws_instance_roles = ["Role_Allinone", "Role_PNode"]
  gcp_host_project_id       = "my-project-123456"
  org_id                    = "123456789012"
  service_account_name      = "uptycs-gcr-integration"
  
  # From Uptycs UI: "Configurations" -> "Registry Configuration" -> "ADD REGISTRY"
  uptycs_aws_account_id     = "012345678901"
  integration_name          = "uptycs-gcr-org-integration"
  
  # Enable legacy GCR integration if needed
  gcr_integration           = false
}
