# Workloads Spec

## E-Commerce Storefront
- **Azure Target:** Azure App Service
- **SLA:** 99.9% uptime required
- **Peak Traffic:** Black Friday / seasonal sales — up to 5x normal load
- **RPO:** 1 hour
- **RTO:** 4 hours
- **Dependencies:** Product Catalogue API, Blob Storage (product images)
- **Users:** Public internet customers
- **Data:** Customer PII (names, addresses), payment data processed via third-party payment gateway (Stripe) — card data never stored in Azure

## Product Catalogue API
- **Azure Target:** Azure Container Apps
- **SLA:** Must match storefront — 99.9%
- **Peak Traffic:** Driven by storefront — scales with it
- **RPO:** 4 hours
- **RTO:** 8 hours
- **Dependencies:** Azure Container Registry (image source)
- **Users:** Internal only — consumed by the storefront, not public-facing directly

## Internal HR & Finance App
- **Azure Target:** Azure Virtual Machine (Windows Server)
- **SLA:** Business hours availability (Mon–Fri 08:00–18:00 GMT) — planned downtime outside these hours acceptable
- **RPO:** 24 hours
- **RTO:** 8 hours
- **Dependencies:** Finance file shares (Azure Files), Entra ID authentication
- **Users:** Finance department (London), IT Manager
- **Data:** Employee PII, payroll data — sensitive, must not be publicly accessible

## Finance File Shares
- **Azure Target:** Azure Files (Premium — FileStorage account kind, SSD-backed)
- **Capacity:** ~500GB current, expected to grow to 1TB over 3 years
- **Access Pattern:** Read/write during business hours, read-only outside
- **RPO:** 24 hours
- **RTO:** 8 hours
- **Users:** Finance department only (up to 11 concurrent users)
- **Data:** Sensitive financial records
- **Reasoning for Premium:** Team of 11 concurrent users requires consistent low-latency IOPS — HDD-backed Standard would cause performance issues
- **Provisioned capacity at launch:** 600GB — 500GB current data plus 100GB headroom for migration variance and immediate post-migration growth
- **Scaling strategy:** Scale in 100GB increments when the 90% capacity alert fires. Alert threshold set to 90% (not 80%) because 100GB increments provide sufficient headroom between alert and capacity limit. See operations.md for alert config.

## Product Images & Marketing Assets
- **Azure Target:** Azure Blob Storage
- **Capacity:** ~200GB current, expected to grow significantly
- **Access Pattern:** Frequent reads (public CDN delivery), less frequent writes (marketing uploads)
- **RPO:** 48 hours
- **RTO:** 24 hours
- **Users:** Marketing team (write), public internet (read via storefront)
- **Data:** Non-sensitive marketing assets

## Container Registry
- **Azure Target:** Azure Container Registry
- **Users:** Cloud Engineers (push), Container Apps (pull)
- **Images:** Product Catalogue API image
