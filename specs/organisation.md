# Organisation Spec

## Org Chart

### IT (London — 6 people)
| Title | Count | Azure Responsibility |
|---|---|---|
| IT Manager | 1 | Oversees Azure estate, approves changes |
| Cloud Engineer | 2 | Day-to-day Azure infrastructure management |
| IT Support Technician | 3 | Helpdesk & device management — no Azure access needed |

### Finance (London — 12 people)
| Title | Count | Azure Responsibility |
|---|---|---|
| Head of Finance | 1 | Read access to cost management |
| Finance Analyst | 6 | Read/write access to Finance file shares only |
| Accounts Payable/Receivable | 5 | Read/write access to Finance file shares only |

### Marketing (London — 15 people)
| Title | Count | Azure Responsibility |
|---|---|---|
| Head of Marketing | 1 | None |
| Digital Marketing Manager | 2 | Read/write access to product image Blob Storage |
| Content & Creative | 12 | Read/write access to product image Blob Storage |

### Warehouse & Ops (Manchester — 80 people)
| Title | Count | Azure Responsibility |
|---|---|---|
| Operations Manager | 2 | None |
| Warehouse Staff | 78 | None — no Azure access required |

### Regional Sales (Edinburgh — 40 people)
| Title | Count | Azure Responsibility |
|---|---|---|
| Regional Sales Manager | 2 | None |
| Sales Associates | 38 | None — no Azure access required |

## RBAC Design Decisions

### Grouping Strategy
- Title-based groups — groups reflect who people are, built-in roles define what they can do
- Groups created even for single users — easier offboarding and role changes
- No custom roles — built-in roles only

### Groups & Role Assignments

| Group | Built-in Role | Scope | Reasoning |
|---|---|---|---|
| IT-Manager | Monitoring Reader | Prod RG | Needs visibility of alerts, metrics, and activity logs in production |
| IT-Manager | Contributor | Prod RG | Out-of-hours emergency access to fix production incidents |
| Cloud-Engineers | Contributor | Non-prod RG | Permanent — day-to-day infrastructure management |
| Cloud-Engineers | Monitoring Reader | Prod RG | Permanent — visibility of production alerts and metrics |
| Cloud-Engineers | Monitoring Reader | Non-prod RG | Permanent — visibility of non-prod alerts and metrics |
| Cloud-Engineers | Contributor | Prod RG | PIM-eligible — activated on request for prod deployments, approved by IT Manager |
| Finance-Analysts | Storage File Data SMB Share Contributor | Finance file share | Scoped to share level — multiple shares may exist on the storage account in future |
| Accounts-PayableReceivable | Storage File Data SMB Share Contributor | Finance file share | Same access as Finance Analysts — separate group for organisational clarity |
| Head-of-Finance | Cost Management Reader | Subscription | Read access to cost data and budgets across the full subscription |
| Digital-Marketing-Managers | Storage Blob Data Contributor | Product images container | Scoped to container — storage account would expose other storage types |
| Content-Creative | Storage Blob Data Contributor | Product images container | Same access as Digital Marketing Managers — separate group for organisational clarity |
| External-Contractors | AcrPush | Non-prod ACR resource | Push/pull images only — Contributor too broad for external users |
| External-Contractors | Website Contributor | Non-prod App Service resource | Deploy and configure app — cannot delete or touch other resources |

> IT Support Technicians, Warehouse Staff, Ops Managers, Sales — no Azure access required, no groups needed.

---

## External Users
- 2x contracted developers working on the e-commerce storefront — need access to non-prod App Service and Container Registry only
- Access granted as Entra B2B guest users, scoped to non-prod resource group
