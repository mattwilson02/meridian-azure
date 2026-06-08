# Data Spec

## Data Classification

| Classification | Description | Examples |
|---|---|---|
| Public | No restrictions — can be served to internet | Product images, marketing assets |
| Internal | Business use only — not for public access | Operational data, internal docs |
| Confidential | Sensitive business data — restricted access | Finance records, contracts |
| Restricted | Personal or regulated data — strictest controls | Employee PII, customer PII |

## Data Inventory

| Workload | Data | Classification | Contains PII |
|---|---|---|---|
| E-commerce storefront | Customer accounts, order history, addresses | Restricted | Yes — customer |
| HR & Finance app | Payroll, employee records | Restricted | Yes — employee |
| Finance file shares | Financial reports, invoices | Confidential | Minimal |
| Product images | Marketing assets, product photos | Public | No |
| Product Catalogue API | Product names, prices, descriptions | Internal | No |

## Retention Requirements
| Data | Retention Period | Reason |
|---|---|---|
| Finance records | 7 years | UK HMRC legal requirement |
| Employee records | Duration of employment + 6 years | UK employment law |
| Customer order history | 3 years | Business requirement |
| Application logs | 90 days | Operational requirement |
| Backup snapshots | 30 days | As per NFR |

## Residency
- All data must remain in `uksouth` or `ukwest` — enforced via Azure Policy
- No geo-replication to regions outside UK
