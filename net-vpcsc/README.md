# Network VPC Service Controls

This Terraform configuration implements Google Cloud VPC Service Controls (VPC-SC) for the fintech production infrastructure, providing data exfiltration protection and API access control across multiple projects.

## Overview

The `net-vpcsc` module creates a comprehensive security perimeter around the fintech production projects, implementing:

- **Data Exfiltration Protection**: Prevents unauthorized data transfer outside the security perimeter
- **API Access Control**: Restricts access to Google Cloud APIs based on identity and location
- **Identity-Based Access**: Defines trusted user groups with specific access levels
- **Multi-Project Security**: Encompasses host, GKE, and data projects in a unified security perimeter

## Architecture

```
┌─────────────────────────────────────────────────────────────  ┐
│                    VPC Service Controls Perimeter             │
├─────────────────────────────────────────────────────────────  ┤
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                Access Policy                            │  │
│  │  ┌─────────────────────────────────────────────────────┐│  │
│  │  │ • Organization: cloudon-one.com                             ││  │
│  │  │ • Policy Name: fintech-prod-access-policy             ││  │
│  │  │ • Description: fintech Production Access Control      ││  │
│  │  └─────────────────────────────────────────────────────┘│  │
│  └─────────────────────────────────────────────────────────┘  │
│                              │                                │
│                              │                                │
│  ┌───────────────────────────┼───────────────────────────────┐│
│  │                           │                               ││
│  │  ┌─────────────────────┐  │  ┌─────────────────────────┐  ││
│  │  │   Access Level      │  │  │   Service Perimeter     │  ││
│  │  │                     │  │  │                         │  ││
│  │  │ • Name: fintech_devops│  │  │ • Type: REGULAR         │  ││
│  │  │   _access           │  │  │ • Status: ACTIVE        │  ││
│  │  │ • Trusted Groups:   │  │  │ • Projects:             │  ││
│  │  │   - fintech-technology│  │  │   - Host Project        │  ││
│  │  │     -devops@cloudon-one.com │  │  │   - GKE Project         │  ││
│  │  │ • Conditions:       │  │  │   - Data Project        │  ││
│  │  │   - Identity-based  │  │  │ • Restricted Services:  │  ││
│  │  │   - Location-based  │  │  │   - Storage APIs        │  ││
│  │  │                     │  │  │   - Compute APIs        │  ││
│  │  │                     │  │  │   - Database APIs       │  ││
│  │  │                     │  │  │   - Analytics APIs      │  ││
│  │  └─────────────────────┘  │  │   - Messaging APIs      │  ││
│  │                           │  │                         │  ││
│  └───────────────────────────┴──┴─────────────────────────┘  ││
│                                                              ││
│  ┌────────────────────────────────────────────────────────┐  ││
│  │                Protected Projects                      │  ││
│  │                                                        │  ││
│  │  ┌─────────────────┐  ┌─────────────────┐              │  ││
│  │  │  Host Project   │  │   GKE Project   │              │  ││
│  │  │                 │  │                 │              │  ││
│  │  │ • VPC Networks  │  │ • GKE Clusters  │              │  ││
│  │  │ • Firewall Rules│  │ • Applications  │              │  ││
│  │  │ • DNS Zones     │  │ • Load Balancers│              │  ││
│  │  └─────────────────┘  └─────────────────┘              │  ││
│  │                                                        │  ││
│  │  ┌─────────────────────────────────────────────────────┐ │││
│  │  │              Data Project                           │ │││
│  │  │                                                     │ │││
│  │  │ • Cloud SQL Instances                               │ │││
│  │  │ • Memorystore Redis                                 │ │││
│  │  │ • BigQuery Datasets                                 │ │││
│  │  │ • Cloud Storage Buckets                             │ │││
│  │  └─────────────────────────────────────────────────────┘ │││
│  └─────────────────────────────────────────────────────────┘│ │
└─────────────────────────────────────────────────────────────┘ │
                                                                │
┌─────────────────────────────────────────────────────────────┐ │
│                    External Access                          │ │
│                                                             │ │
│ • Identity-Aware Proxy (IAP)                                │ │
│ • Cloud Load Balancing                                      │ │
│ • Cloud Armor                                               │ │
│ • External APIs (controlled access)                         │ │
└─────────────────────────────────────────────────────────────┘ │
                                                                │
┌─────────────────────────────────────────────────────────────┐ │
│                    Ingress/Egress Policies                  │ │
│                                                             │ │
│ • Ingress: Allow from trusted sources only                  │ │
│ • Egress: Restrict data exfiltration                        │ │
│ • Identity: Require trusted group membership                │ │
│ • Location: Enforce geographic restrictions                 │ │
└─────────────────────────────────────────────────────────────┘ │
```

## Components

### 1. Access Policy

- **Organization Level**: Created at the organization level for centralized control
- **Policy Name**: `fintech-prod-access-policy`
- **Description**: Comprehensive access control for fintech production environment
- **Scope**: Organization-wide policy that can contain multiple service perimeters

### 2. Access Level

- **Name**: `fintech_devops_access`
- **Trusted Groups**: `fintech-technology-devops@cloudonpone`
- **Access Type**: Identity-based access control
- **Conditions**: 
  - Identity verification required
  - Location-based restrictions (if configured)
  - Device compliance requirements (if configured)

### 3. Service Perimeter

- **Type**: `PERIMETER_TYPE_REGULAR`
- **Status**: `ACTIVE`
- **Protected Projects**:
  - Host Project: `fintech-prod-host-project-8hhr`
  - GKE Project: `fintech-prod-gke-project-3ypz`
  - Data Project: `fintech-prod-data-project-mnch`

### 4. Restricted Services

The perimeter restricts access to the following Google Cloud services:

#### Storage & Data Services

- `storage.googleapis.com` - Cloud Storage
- `bigquery.googleapis.com` - BigQuery

#### Compute & Infrastructure

- `compute.googleapis.com` - Compute Engine
- `container.googleapis.com` - Google Kubernetes Engine
- `containerregistry.googleapis.com` - Container Registry

#### Database Services

- `sqladmin.googleapis.com` - Cloud SQL

#### Analytics & Machine Learning

- `dataflow.googleapis.com` - Dataflow
- `dataproc.googleapis.com` - Dataproc
- `ml.googleapis.com` - Cloud ML Engine

#### Messaging & Networking

- `pubsub.googleapis.com` - Pub/Sub
- `dns.googleapis.com` - Cloud DNS

## Usage

### Basic Configuration

```hcl
module "vpc_service_controls" {
  source = "./net-vpcsc"

  # Organization Configuration
  organization_id = "123456789012"

  # Project Configuration
  host_project_id = "fintech-prod-host-project-8hhr"
  gke_project_id  = "fintech-prod-gke-project-3ypz"
  data_project_id = "fintech-prod-data-project-mnch"
}
```

### Advanced Configuration

```hcl
module "vpc_service_controls" {
  source = "./net-vpcsc"

  # Organization Configuration
  organization_id = "123456789012"

  # Project Configuration
  host_project_id = "fintech-prod-host-project"
  gke_project_id  = "fintech-prod-gke-project"
  data_project_id = "fintech-prod-data-project"

  # Custom Configuration
  perimeter_name = "fintech-prod-perimeter"
  access_level_name = "fintech_devops_access"
  
  # Trusted Groups (optional - defaults to fintech-technology-devops@cloudon-one.com)
  trusted_groups = [
    "fintech-technology-devops@cloudon-one.com",
    "fintech-security@cloudon-one.com"
  ]

  # Custom Restricted Services (optional - uses defaults if not specified)
  restricted_services = [
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "redis.googleapis.com"
  ]

  # Perimeter Configuration
  perimeter_type = "PERIMETER_TYPE_REGULAR"
  use_explicit_dry_run_spec = false

  # Labels
  labels = {
    environment = "production"
    team        = "security"
    compliance  = "required"
    data_classification = "confidential"
  }
}
```

## Configuration Variables

### Core Configuration

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|:--------:|
| `organization_id` | The organization ID for creating access policy | `string` | n/a | yes |
| `host_project_id` | The host project ID to include in perimeter | `string` | n/a | yes |
| `gke_project_id` | The GKE project ID to include in perimeter | `string` | n/a | yes |
| `data_project_id` | The data project ID to include in perimeter | `string` | n/a | yes |

### Custom Configuration

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|:--------:|
| `perimeter_name` | Name of the service perimeter | `string` | `"fintech-prod-perimeter"` | no |
| `access_level_name` | Name of the access level | `string` | `"fintech_devops_access"` | no |
| `trusted_groups` | List of trusted Google Groups for access | `list(string)` | `["fintech-technology-devops@cloudon-one.com"]` | no |
| `restricted_services` | List of services to restrict in the perimeter | `list(string)` | See below | no |
| `perimeter_type` | Type of perimeter | `string` | `"PERIMETER_TYPE_REGULAR"` | no |
| `use_explicit_dry_run_spec` | Whether to use explicit dry run specification | `bool` | `false` | no |
| `labels` | Labels to apply to resources | `map(string)` | `{}` | no |

## Default Restricted Services

```hcl
[
  "storage.googleapis.com",
  "bigquery.googleapis.com",
  "bigtable.googleapis.com",
  "datastore.googleapis.com",
  "compute.googleapis.com",
  "container.googleapis.com",
  "containerregistry.googleapis.com",
  "sqladmin.googleapis.com",
  "dataflow.googleapis.com",
  "dataproc.googleapis.com",
  "ml.googleapis.com",
  "pubsub.googleapis.com",
  "dns.googleapis.com"
]
```

## Outputs

| Output | Description |
|--------|-------------|
| `access_policy_id` | The ID of the access policy |
| `access_policy_name` | The name of the access policy |
| `service_perimeter_name` | The name of the service perimeter |
| `access_level_name` | The name of the access level |
| `restricted_services` | List of services restricted by the perimeter |
| `protected_projects` | List of projects protected by the perimeter |

### Output Example

```hcl
access_policy_id = "accessPolicies/123456789012"
access_policy_name = "fintech-prod-access-policy"
service_perimeter_name = "fintech-prod-perimeter"
access_level_name = "fintech_devops_access"
restricted_services = [
  "storage.googleapis.com",
  "bigquery.googleapis.com",
  "compute.googleapis.com",
  "container.googleapis.com"
]
protected_projects = [
  "fintech-prod-host-project-8hhr",
  "fintech-prod-gke-project-3ypz",
  "fintech-prod-data-project-mnch"
]
```

## Security Policies

### Ingress Policies

#### From Internal Sources

- **Source**: Other projects within the perimeter
- **Operations**: All operations allowed
- **Identity**: Any authenticated user within the perimeter
- **Location**: No restrictions

#### From External Sources

- **Source**: Outside the perimeter
- **Operations**: Limited to essential operations
- **Identity**: Must be in trusted DevOps group
- **Location**: Enforced geographic restrictions (if configured)

### Egress Policies

#### To Internal Destinations

- **Destination**: Projects within the perimeter
- **Operations**: All operations allowed
- **Identity**: Any authenticated user within the perimeter

#### To External Destinations

- **Destination**: Outside the perimeter
- **Operations**: Restricted based on service and identity
- **Identity**: Must be in trusted DevOps group
- **Data**: Prevented data exfiltration

## Access Control Matrix

| Service | Trusted Group | External Users | Internal Users |
|---------|---------------|----------------|----------------|
| Storage APIs | ✅ Full Access | ❌ Denied | ✅ Full Access |
| Compute APIs | ✅ Full Access | ❌ Denied | ✅ Full Access |
| Database APIs | ✅ Full Access | ❌ Denied | ✅ Full Access |
| Analytics APIs | ✅ Full Access | ❌ Denied | ✅ Full Access |
| Messaging APIs | ✅ Full Access | ❌ Denied | ✅ Full Access |

## Compliance and Governance

### Data Protection

- **Data Exfiltration Prevention**: VPC-SC prevents unauthorized data transfer
- **API Access Control**: Restricts access to sensitive APIs
- **Identity Verification**: Ensures only authorized users can access resources

### Audit and Monitoring

- **Access Logging**: All access attempts are logged
- **Policy Violations**: Failed access attempts are recorded
- **Compliance Reporting**: Regular reports on access patterns

### Regulatory Compliance

- **GDPR**: Data protection and access control
- **SOX**: Financial data protection
- **HIPAA**: Healthcare data security (if applicable)
- **ISO 27001**: Information security management

## Dependencies

This module depends on the following Terraform configurations:
- `svc-projects` - Provides project IDs for the perimeter

## Prerequisites

### Required Permissions

The user or service account running Terraform must have:

1. **Organization Level**:
   - `roles/accesscontextmanager.policyAdmin` - Create and manage access policies
   - `roles/accesscontextmanager.policyEditor` - Edit access policies

2. **Project Level**:
   - `roles/serviceusage.serviceUsageViewer` - View enabled services

### Required APIs

The following APIs must be enabled in the organization:

- `accesscontextmanager.googleapis.com` - Access Context Manager API

### Google Groups

Trusted Google Groups must exist and be accessible:

- `fintech-technology-devops@cloudon-one.com` - Primary DevOps team
- Additional groups as specified in configuration

## Troubleshooting

### Common Issues

1. **Access Denied Errors**
   - Verify user is in the trusted Google Group
   - Check that the service perimeter is active
   - Ensure the API is not in the restricted services list

2. **Policy Creation Failures**
   - Verify organization-level permissions
   - Check that Access Context Manager API is enabled
   - Ensure project IDs are correct and accessible

3. **Service Perimeter Issues**
   - Verify all projects exist and are accessible
   - Check that no conflicting perimeters exist
   - Ensure proper IAM permissions on all projects

### Debugging Commands

```bash
gcloud access-context-manager policies list --organization=ORGANIZATION_ID
gcloud access-context-manager perimeters describe PERIMETER_NAME --policy=POLICY_ID
gcloud access-context-manager levels describe LEVEL_NAME --policy=POLICY_ID

gcloud auth list
gcloud config get-value project
gcloud storage ls
```

### Monitoring and Alerts

```bash
gcloud logging read "resource.type=gce_instance AND protoPayload.serviceName=accesscontextmanager.googleapis.com"

gcloud logging read "resource.type=gce_instance AND protoPayload.authenticationInfo.principalEmail:*"
```

## Best Practices

### Security Design

- **Principle of Least Privilege**: Grant minimum required access
- **Defense in Depth**: Multiple layers of security controls
- **Zero Trust**: Verify every access attempt

### Policy Management

- **Regular Reviews**: Periodically review access policies
- **Change Management**: Document all policy changes
- **Testing**: Test policies in dry-run mode before activation

### Monitoring

- **Real-time Alerts**: Set up alerts for policy violations
- **Regular Audits**: Conduct periodic access reviews
- **Compliance Reporting**: Generate compliance reports

## Related Documentation

- [VPC Service Controls](https://cloud.google.com/vpc-service-controls/docs)
- [Access Context Manager](https://cloud.google.com/access-context-manager/docs)
- [Service Perimeter](https://cloud.google.com/vpc-service-controls/docs/service-perimeters)
- [Access Levels](https://cloud.google.com/access-context-manager/docs/access-levels)
- [Security Best Practices](https://cloud.google.com/security/best-practices) 