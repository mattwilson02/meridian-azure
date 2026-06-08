# Networking Spec

## On-Premises IP Ranges
| Site | Network | Subnet |
|---|---|---|
| London HQ | 192.168.1.0/24 | 192.168.1.0/26 (servers), 192.168.1.64/26 (workstations) |
| Manchester | 192.168.2.0/24 | 192.168.2.0/26 (servers), 192.168.2.64/26 (workstations) |
| Edinburgh | 192.168.3.0/24 | 192.168.3.0/26 (workstations) |

## Connectivity Requirements
- **On-prem to Azure:** Site-to-site VPN (not ExpressRoute — budget constraint). London HQ is the primary connection point
- **Manchester & Edinburgh:** Connect to Azure via London HQ (hub model) — no direct Azure connectivity required initially
- **Internet-facing workloads:** E-commerce storefront, product images (CDN). All others private

## Workload Connectivity
| Workload | Internet-Facing | Needs Private Connectivity To |
|---|---|---|
| E-commerce storefront | Yes (public) | Product Catalogue API, Blob Storage |
| Product Catalogue API | No | Container Registry |
| HR & Finance VM | No | Finance file shares, Entra ID |
| Finance file shares | No | HR & Finance VM, Finance user devices |
| Product images | Yes (read-only, CDN) | Marketing team devices |
| Bastion | Yes (HTTPS only) | All VMs in private subnets |

## DNS
- Internal services resolved via Azure Private DNS Zones
- Public DNS for e-commerce storefront managed externally (existing domain registrar)
- On-prem DNS to be replaced by Azure Private DNS Zones post-migration

## Admin Access
- No RDP or SSH exposed to public internet
- All VM management via Azure Bastion
