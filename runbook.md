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

Deploys: resource groups, policies, role assignments, budgets.

### 2.1 What-if (preview before deploying)
```bash
az deployment sub what-if \
  --location uksouth \
  --template-file infra/main.bicep \
  --parameters infra/parameters/dev.local.bicepparam
```

### 2.2 Deploy
```bash
az deployment sub create \
  --location uksouth \
  --template-file infra/main.bicep \
  --parameters infra/parameters/dev.local.bicepparam
```

### 2.3 Verify in portal
- [ ] **Resource groups** — `rg-meridian-prod-uks` and `rg-meridian-nonprod-uks` visible
- [ ] **Policy → Assignments** — 5 assignments visible (deny-nonuk-locations, audit-owner-tag, audit-costcentre-tag, modify-environment-tag x2)
- [ ] **Entra ID → Groups** — role assignments visible on IT-Manager, Cloud-Engineers, Head-of-Finance groups
- [ ] **Cost Management → Budgets** — 4 budgets visible (or verify via CLI: `az consumption budget list -o table`)

> **Note:** PIM-eligible Contributor for Cloud Engineers requires Entra ID P2 licence. Set `enablePim = true` in `dev.local.bicepparam` once a P2 tenant is available.

---

## 3. Storage Module Deployment

Deploys: Premium FileStorage account + Finance file share (prod), Standard GPv2 assets account + container (prod), Standard GPv2 general account + container (non-prod).

No manual prerequisites — runs as part of the same deployment as foundation.

### 3.1 What-if and Deploy
Same commands as section 2 — storage module is wired into `infra/main.bicep` and deploys automatically.

### 3.2 Verify in portal
- [ ] **rg-meridian-prod-uks** → Storage accounts: `stmeridianfinanceuks` (FileStorage, Premium_LRS) and `stmeridianassetsuks` (StorageV2, Standard_GRS)
- [ ] **rg-meridian-nonprod-uks** → Storage accounts: `stmeridiannonproduks` (StorageV2, Standard_LRS)
- [ ] Finance share `finance` exists with 600GB quota under `stmeridianfinanceuks`
- [ ] Container `assets` exists with no public access under both blob storage accounts

---

## 4. Compute Module

Deploys: VNet + compute subnet, Windows Server VM (HR/Finance), Recovery Services Vault, daily backup policies for VM and finance file share.

### 4.1 Prerequisites
- Set `vmAdminPassword` in `infra/parameters/dev.local.bicepparam` (12+ chars, upper, lower, number, special character)

### 4.2 Deploy
```bash
az deployment sub create \
  --location uksouth \
  --template-file infra/main.bicep \
  --parameters infra/parameters/dev.local.bicepparam
```

> **Note:** `what-if` fails on this stack due to a known ARM planner issue with PIM preview API types — skip straight to deploy.

### 4.3 Verify in portal
- [ ] **rg-meridian-prod-uks** → Virtual networks: `vnet-meridian-prod-uks` with subnet `snet-compute-prod-uks`
- [ ] **rg-meridian-prod-uks** → Virtual machines: `vm-hrfinance-prod-uks` (Standard_D2s_v3, Windows Server 2022)
- [ ] **rg-meridian-prod-uks** → Recovery Services vaults: `rsv-meridian-prod-uks`
- [ ] Vault → Backup items: VM `vm-hrfinance-prod-uks` and file share `finance` both listed

### 4.4 Cost management — deallocate VM between study sessions
A D2s_v3 running 24/7 costs ~£70/month. Deallocate it when not in use — no compute charge while deallocated, disk storage only (~£2/month).

```bash
# Deallocate (stop billing for compute)
az vm deallocate \
  --resource-group rg-meridian-prod-uks \
  --name vm-hrfinance-prod-uks

# Start again when needed
az vm start \
  --resource-group rg-meridian-prod-uks \
  --name vm-hrfinance-prod-uks
```

---

## 5. Containers Module Prerequisites

> To be completed when containers module is designed.

---

## 6. App Service Module Prerequisites

> To be completed when app service module is designed.

---

## 7. Networking Module Prerequisites

> To be completed when networking module is designed.

---

## 8. Monitoring Module Prerequisites

> To be completed when monitoring module is designed.
