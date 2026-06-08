# meridian-azure

Infrastructure-as-Code for Meridian Retail's Azure migration. Built in Bicep, covering identity, governance, compute, networking, and monitoring across a realistic multi-workload environment.

> **Note:** Meridian Retail is a fictional company. This project is a study scenario designed to simulate the role of an Azure Administrator across a full cloud migration.

## What's in here

- `scenario.md` — business brief and requirements
- `specs/` — detailed technical and organisational specifications
- `infra/` — Bicep modules, built incrementally by domain
- `runbook.md` — deployment steps including manual prerequisites

## Architecture

Infrastructure is organised into modules that map to the AZ-104 exam domains:

| Module | Domain | Status |
|---|---|---|
| `foundation` | Identity, Governance | In progress |
| `compute` | Virtual Machines | Pending |
| `containers` | Containers | Pending |
| `app-service` | App Service | Pending |
| `networking` | Virtual Networking | Pending |
| `monitoring` | Monitor & Maintain | Pending |
