# Meridian Retail — Business Scenario

## Company Overview
Meridian Retail is a UK-based fashion retailer with 300 employees across three sites: London (HQ), Manchester (warehouse & fulfilment), and Edinburgh (regional office). They've been running everything on-premises for 10 years and are now doing a full migration to Azure over 12 months. You are the Azure Administrator on the project.

## Sites
| Site | Role | Users |
|---|---|---|
| London | HQ, IT, Finance, Marketing | 180 |
| Manchester | Warehouse, Ops | 80 |
| Edinburgh | Regional Sales | 40 |

## Workloads to Migrate
| Workload | Current State | Azure Target |
|---|---|---|
| E-commerce storefront | On-prem IIS / Windows Server | Azure App Service |
| Product catalogue API | On-prem .NET microservice | Azure Container Apps |
| Container image registry | Local Docker registry | Azure Container Registry |
| Internal HR & Finance app | Windows Server VM | Azure Virtual Machine |
| Finance file shares | On-prem NAS | Azure Files |
| Product images & marketing assets | Local file server | Azure Blob Storage |
| Secure admin access | VPN appliance | Azure Bastion |
| Internal DNS | On-prem Windows DNS | Azure Private DNS Zones |

---

## Non-Functional Requirements
- **Availability:** The e-commerce site must tolerate a single VM/instance failure
- **Security:** No management ports (RDP/SSH) exposed to the public internet
- **Governance:** All resources must be tagged with `environment`, `owner`, and `costCentre`
- **Cost:** Non-production resources should be easy to identify and shut down
- **Compliance:** All data must remain in UK regions (`uksouth` / `ukwest`)
- **Backup:** VMs and file shares must have daily backups with 30-day retention
- **Monitoring:** Ops team must be alerted on VM CPU > 80% and App Service 5xx errors

## Azure Environment
- Single subscription (for now — may grow to multiple later)
- Two resource groups at minimum: production and non-production
- All infrastructure managed via Bicep

---

## Architecture Modules (built incrementally)

| Module | Exam Domain | Status |
|---|---|---|
| `foundation` | Domain 1 — Identity & Governance + Domain 2 — Storage | Retroactive scaffold |
| `compute` | Domain 3 — Virtual Machines | Next |
| `containers` | Domain 3 — Containers | Pending |
| `app-service` | Domain 3 — App Service | Pending |
| `networking` | Domain 4 — Virtual Networking | Pending |
| `monitoring` | Domain 5 — Monitor & Maintain | Pending |
