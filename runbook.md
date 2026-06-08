# Meridian Retail — Deployment Runbook

This runbook documents every step required to deploy the full Meridian Retail Azure environment, including prerequisites that cannot be automated via Bicep and manual steps that must be completed in order.

---

## 0. Account & Tooling Prerequisites

These must be in place before anything else.

- [ ] Azure account provisioned (free account or pay-as-you-go)
- [ ] Azure CLI installed — `az --version`
- [ ] Bicep CLI installed — `az bicep install`
- [ ] Logged in to Azure — `az login`
- [ ] Correct subscription selected — `az account set --subscription "Azure subscription 1"`

---

## 1. Foundation Module Prerequisites

These steps must be completed manually before deploying `modules/foundation`.

### 1.1 Entra ID Tenant
- [ ] Confirm Entra ID tenant exists (created automatically with any Microsoft cloud account)
- [ ] Note tenant ID — `az account show --query tenantId`

### 1.2 Entra Connect (Hybrid Identity)
Entra Connect is on-premises software — it cannot be deployed via Bicep.

- [ ] Identify a Windows Server 2016+ machine on the Meridian on-premises network to act as the sync server
- [ ] Download Entra Connect from Microsoft Download Center
- [ ] Run the installation wizard — choose **Express Settings** for a single AD forest
- [ ] Verify sync completed: Azure Portal → Entra ID → Users → confirm on-prem accounts appear
- [ ] Confirm sync method: **Password Hash Sync** (simplest, recommended for this scenario)

> **Why Password Hash Sync?** Doesn't require ADFS infrastructure, syncs password hashes so users can authenticate directly against Entra ID even if on-prem connectivity drops.

### 1.3 Management Group Hierarchy
- [ ] Confirm root management group exists (auto-created with subscription)
- [ ] Foundation Bicep will create child management groups — no manual step needed

### 1.4 External Contractor Offboarding
PIM is not used for B2B guest users — access is managed manually.

- [ ] When a contractor contract ends, remove the guest user from the `External-Contractors` Entra group immediately
- [ ] Delete the B2B guest user account from Entra ID
- [ ] Verify no residual role assignments remain on the non-prod ACR and App Service resources

### 1.5 Entra Group Creation

Groups are created via CLI — the Microsoft Graph Bicep extension is not stable enough for production use.
Create all groups before deploying the foundation module. Only 3 IDs are needed for the current deployment
(`dev.bicepparam`); the remaining groups are used in later modules when storage resources are provisioned.

```bash
# Create groups
az ad group create --display-name "IT-Manager" --mail-nickname "IT-Manager"
az ad group create --display-name "Cloud-Engineers" --mail-nickname "Cloud-Engineers"
az ad group create --display-name "Head-of-Finance" --mail-nickname "Head-of-Finance"
az ad group create --display-name "Finance-Analysts" --mail-nickname "Finance-Analysts"
az ad group create --display-name "Accounts-PayableReceivable" --mail-nickname "Accounts-PayableReceivable"
az ad group create --display-name "Digital-Marketing-Managers" --mail-nickname "Digital-Marketing-Managers"
az ad group create --display-name "Content-Creative" --mail-nickname "Content-Creative"
az ad group create --display-name "External-Contractors" --mail-nickname "External-Contractors"
```

```bash
# Retrieve object IDs needed for dev.bicepparam
az ad group show --group "IT-Manager" --query id -o tsv
az ad group show --group "Cloud-Engineers" --query id -o tsv
az ad group show --group "Head-of-Finance" --query id -o tsv
```

- [ ] Paste the 3 object IDs into `infra/parameters/dev.bicepparam` replacing the placeholder values

---

## 2. Foundation Module Deployment

> **Design decisions to be documented here once foundation module is designed.**

---

## 3. Compute Module Prerequisites

> To be completed when compute module is designed.

---

## 4. Containers Module Prerequisites

> To be completed when containers module is designed.

---

## 5. App Service Module Prerequisites

> To be completed when app service module is designed.

---

## 6. Networking Module Prerequisites

> To be completed when networking module is designed.

---

## 7. Monitoring Module Prerequisites

> To be completed when monitoring module is designed.
