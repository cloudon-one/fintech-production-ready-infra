# Resource Type	

- GKE Project Name: fintech-prod-gke-svc-<random-string>
- GKE Cluster Name: fintech-prod-gke-cluster
- GKE VPC CIDR Block: - 10.60.0.0/16
- Nodes Subnet CIDR Block: 10.60.4.0/22
- GKE Control Plane  CIDR Block (gke-vpc): 10.60.1.0/28
- Pod Secondary Range: 10.60.128.0/17
- Service Secondary Range: 10.60.8.0/22

## Node pools	

- app-pool VM type:	n2-standard-2
- service-pool VM type: e2-medium