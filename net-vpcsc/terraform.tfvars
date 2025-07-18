organization_id = ""
host_project_id = "fintech-prod-host-project"
gke_project_id  = "fintech-prod-gke-project"
data_project_id = "fintech-prod-data-project"

devops_team_members = [
  "user:devops1@cloudon-one.com"
]

backend_team_members = [
  "group:fintech-technology-backend@cloudon-one.com"
]

frontend_team_members = [
  "group:fintech-technology-frontend@cloudon-one.como"
]

mobile_team_members = [
  "group:fintech-technology-mobile@cloudon-one.com"
]

service_accounts = [
  "serviceAccount:bastion-prod-host@fintech-prod-host-project.iam.gserviceaccount.com",
  "serviceAccount:gke-service-account@fintech-prod-gke-project.iam.gserviceaccount.com",
  "serviceAccount:cloudsql-admin@fintech-prod-data-project.iam.gserviceaccount.com"
]

gke_workload_identity_service_accounts = [
  "serviceAccount:fintech-prod-gke-project.svc.id.goog[backend/backend-sa]",
  "serviceAccount:fintech-prod-gke-project.svc.id.goog[frontend/frontend-sa]",
  "serviceAccount:fintech-prod-gke-project.svc.id.goog[api/api-sa]",
  "serviceAccount:fintech-prod-gke-project.svc.id.goog[workers/workers-sa]",
  "serviceAccount:fintech-prod-gke-project.svc.id.goog[monitoring/monitoring-sa]"
]

iap_tunnel_users = [
"user:devops1@cloudon-one.com"
]

restricted_services     = []
bridge_services         = []
vpc_restricted_services = []

 