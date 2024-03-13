module "gcr-config" {
  source = "uptycslabs/gcr-config/google"

  uptycs_aws_account_id     = "Copy/Paste From the Uptycs UI"
  uptycs_aws_instance_roles = ["Copy/Paste From the Uptycs UI"]
  gcp_project_id            = "Your GCP Project ID"
  service_account_name      = "uptycs-gcr-integration"

  # Copy the AWS Account ID from Uptycs UI
  # Uptycs' UI : "Configurations"->"Registry Configuration"->"ADD REGISTRY"
  integration_name = "A unique name for this integration"
}
