# Operations Spec

## Support Model
| Hours | Coverage |
|---|---|
| Mon–Fri 08:00–18:00 GMT | Full support — IT team on-site |
| Out of hours | On-call rota — 1x Cloud Engineer primary, IT Manager secondary |
| Weekends | Critical incidents only via on-call |

## Alerting & Monitoring
| Condition | Threshold | Alert Target |
|---|---|---|
| VM CPU utilisation | > 80% for 5 minutes | Cloud Engineers |
| App Service 5xx errors | > 10 in 5 minutes | Cloud Engineers |
| Storage account capacity | > 80% of provisioned | IT Manager |
| Policy non-compliance | Any new violation | IT Manager |
| Failed backup job | Any failure | Cloud Engineers |
| Entra ID sign-in risk | Medium or High risk detected | IT Manager |

## Backup Windows
- VM backups: 02:00 GMT daily (outside business hours)
- File share backups: 03:00 GMT daily
- Retention: 30 days (as per NFR)

## Change Management
- All infrastructure changes made via Bicep — no ad-hoc Portal changes in prod
- Changes to prod require IT Manager approval
- Non-prod changes can be made by Cloud Engineers without approval
- Rollback plan required for any prod deployment

## On-Call Contacts
| Role | Primary Contact Method |
|---|---|
| Cloud Engineer (on-call) | Mobile — defined at onboarding |
| IT Manager | Mobile — defined at onboarding |
