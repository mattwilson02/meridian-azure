# Compliance & Security Spec

## Policy Design Decisions

### Region Enforcement
- **Policy effect:** Deny
- **Scope:** Root management group (cascades to all subscriptions, RGs, and resources)
- **Allowed locations:** `uksouth`, `ukwest`
- **Reasoning:** Hard compliance requirement — data must never leave UK regions. Deny is appropriate because there is no valid exception.

### Tagging — `environment`
- **Policy effect:** Modify (with remediation task)
- **Scope:** Root management group
- **Value set by policy:** Derived from resource context (subscription/RG)
- **Reasoning:** Policy can set this automatically and consistently. Remediation task patches existing non-compliant resources.

### Tagging — `owner` and `costCentre`
- **Policy effect:** Audit (phased — tighten to Deny post-migration)
- **Scope:** Root management group
- **Reasoning:** Policy cannot supply meaningful values for these tags — they must come from the person creating the resource. Deny is correct long-term, but blocking during migration would grind deployments to a halt. Audit gives visibility without friction now; switch to Deny once migration is stable and tagging is habit.

---

## Regulatory Requirements
| Regulation | Applies To | Key Obligations |
|---|---|---|
| UK GDPR | Customer PII (e-commerce), Employee PII (HR app) | Lawful basis for processing, right to erasure, breach notification within 72 hours |
| PCI-DSS | E-commerce payments | Card data must never be stored — use Stripe as payment gateway, scope Azure out of PCI |
| UK HMRC | Finance records | 7-year retention of financial records |

## Security Policies
- No management ports (RDP/SSH) exposed to the public internet — Bastion required for all VM access
- All storage accounts must disable public blob access by default
- All secrets (connection strings, credentials) stored in Azure Key Vault — not in app config or environment variables
- MFA enforced for all Entra ID accounts with Azure access
- Privileged accounts (Cloud Engineers, IT Manager) require PIM (Privileged Identity Management) for elevated role activation

## Audit Requirements
- All Azure resource changes logged via Azure Activity Log — retained 90 days minimum
- Entra ID sign-in logs retained 30 days minimum
- Finance and HR app access logs retained 1 year
- Alerts on any policy non-compliance within 24 hours

## Vulnerability Management
- VMs must have Microsoft Defender for Cloud enabled
- OS patches applied within 30 days of release for non-critical, 7 days for critical
