# Meridian Retail — Architecture

## Identity & Governance

### Management Group & Subscription Hierarchy

```mermaid
graph TD
    TRG["🏢 Tenant Root Group"]

    TRG -->|"❌ Deny: non-UK regions"| TRG
    TRG -->|"🏷️ Modify: environment tag"| TRG
    TRG -->|"👁️ Audit: owner tag"| TRG
    TRG -->|"👁️ Audit: costCentre tag"| TRG

    TRG --> SUB["📋 Meridian Retail (Subscription)"]

    SUB --> PROD["rg-meridian-prod-uks"]
    SUB --> NONPROD["rg-meridian-nonprod-uks"]

    PROD --> PROD_RES["compute · storage · networking · monitoring"]
    NONPROD --> NONPROD_RES["compute · storage · networking · monitoring"]
```

### Entra Groups & RBAC

```mermaid
graph LR
    subgraph Entra ID Groups
        ITM["IT-Manager"]
        CE["Cloud-Engineers"]
        HOF["Head-of-Finance"]
        FA["Finance-Analysts"]
        APR["Accounts-PayableReceivable"]
        DMM["Digital-Marketing-Managers"]
        CC["Content-Creative"]
        EC["External-Contractors"]
    end

    subgraph Prod RG
        PROD["rg-meridian-prod-uks"]
    end

    subgraph Non-Prod RG
        NONPROD["rg-meridian-nonprod-uks"]
    end

    subgraph Subscription
        SUB["Subscription"]
    end

    ITM -->|"Monitoring Reader"| PROD
    ITM -->|"Contributor"| PROD

    CE -->|"Contributor"| NONPROD
    CE -->|"Monitoring Reader"| PROD
    CE -->|"Monitoring Reader"| NONPROD
    CE -->|"Contributor 🔐 PIM"| PROD

    HOF -->|"Cost Management Reader"| SUB

    FA -->|"File Data SMB Contributor¹"| PROD
    APR -->|"File Data SMB Contributor¹"| PROD
    DMM -->|"Blob Data Contributor²"| PROD
    CC -->|"Blob Data Contributor²"| PROD
    EC -->|"AcrPush³"| NONPROD
    EC -->|"Website Contributor³"| NONPROD
```

> ¹ Scoped to Finance file share — deployed in storage module
> ² Scoped to product images container — deployed in storage module
> ³ Scoped to ACR and App Service resources — deployed in their respective modules

### Cost Budgets

```mermaid
graph LR
    SUB["Subscription"]

    SUB --> B1["💰 Compute\n£800/month\n⚠️ 80% · 🚨 100%"]
    SUB --> B2["💰 Storage\n£150/month\n⚠️ 80% · 🚨 100%"]
    SUB --> B3["💰 Networking\n£300/month\n⚠️ 80% · 🚨 100%"]
    SUB --> B4["💰 Total\n£1,350/month\n⚠️ 80% · 🚨 100%"]
```

---

*Sections will be added as each module is built.*
