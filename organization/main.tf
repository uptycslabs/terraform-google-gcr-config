/*
 * Copyright (c) 2025 Uptycs, Inc. All rights reserved
 */

data "google_service_account" "main_account" {
  count      = var.service_account_exists ? 1 : 0
  account_id = var.service_account_name
  project    = var.gcp_host_project_id
}

data "google_project" "main_project" {
  project_id = var.gcp_host_project_id
}

resource "google_iam_workload_identity_pool" "create_wip" {
  provider                  = google-beta
  project                   = var.gcp_host_project_id
  workload_identity_pool_id = "wip-${var.integration_name}"
  display_name              = "wip-${var.integration_name}"
  description               = "Workload Identity Pool to allow Uptycs integration via AWS federation"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "add_provider" {
  provider                           = google-beta
  project                            = var.gcp_host_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.create_wip.workload_identity_pool_id
  workload_identity_pool_provider_id = "idp-${var.integration_name}"
  aws {
    account_id = var.uptycs_aws_account_id
  }
}

resource "google_service_account" "uptycs_gcr_integration" {
  count        = var.service_account_exists ? 0 : 1
  project      = var.gcp_host_project_id
  account_id   = var.service_account_name
  display_name = var.service_account_name
  description  = "Uptycs GCR Service Account Intergration"
}

resource "google_service_account_key" "uptycs_gcr_integration_key" {
  service_account_id = var.service_account_exists == false ? google_service_account.uptycs_gcr_integration[0].name : data.google_service_account.main_account[0].name
}

resource "google_organization_iam_member" "bind_artifact_registry_reader" {
  org_id =  var.org_id  
  role    = "roles/artifactregistry.reader"
  member  = var.service_account_exists == false ? "serviceAccount:${google_service_account.uptycs_gcr_integration[0].email}" : "serviceAccount:${data.google_service_account.main_account[0].email}"
}

resource "google_organization_iam_member" "bind_iam_service_account_token_creator" {
  org_id =  var.org_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = var.service_account_exists == false ? "serviceAccount:${google_service_account.uptycs_gcr_integration[0].email}" : "serviceAccount:${data.google_service_account.main_account[0].email}"
}

resource "google_organization_iam_member" "bind_storage_object_viewer" {
  count     = var.gcr_integration ? 1 : 0
  org_id =  var.org_id
  role    = "roles/storage.objectViewer"
  member  = var.service_account_exists == false ? "serviceAccount:${google_service_account.uptycs_gcr_integration[0].email}" : "serviceAccount:${data.google_service_account.main_account[0].email}"
}

resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = var.service_account_exists == false ? "${google_service_account.uptycs_gcr_integration[0].name}" : "${data.google_service_account.main_account[0].name}"
  role               = "roles/iam.workloadIdentityUser"
  members = [for each in var.uptycs_aws_instance_roles : format("principalSet://iam.googleapis.com/projects/%s/locations/global/workloadIdentityPools/%s/attribute.aws_role/arn:aws:sts::%s:assumed-role/%s", data.google_project.main_project.number,google_iam_workload_identity_pool.create_wip.workload_identity_pool_id,var.uptycs_aws_account_id, each)]
}

resource "null_resource" "cred_config_json" {
  provisioner "local-exec" {
    command     = "gcloud iam workload-identity-pools create-cred-config projects/${data.google_project.main_project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.create_wip.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.add_provider.workload_identity_pool_provider_id} --service-account=${var.service_account_exists == false ? google_service_account.uptycs_gcr_integration[0].email : data.google_service_account.main_account[0].email} --output-file=credentials.json --aws"
    interpreter = ["/bin/sh", "-c"]
  }
}
