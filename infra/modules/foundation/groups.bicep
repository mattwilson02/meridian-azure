// Entra groups are created via CLI before deploying this module — see runbook.md section 1.5.
// This file documents the expected groups and their purpose.
// Object IDs are passed in as parameters to the top-level deployment.

// Groups created:
//   IT-Manager                — prod monitoring and emergency contributor access
//   Cloud-Engineers           — day-to-day Azure infrastructure management
//   Head-of-Finance           — subscription cost management read access
//   Finance-Analysts          — Finance file share access (role assigned in storage module)
//   Accounts-PayableReceivable — Finance file share access (role assigned in storage module)
//   Digital-Marketing-Managers — product images blob access (role assigned in storage module)
//   Content-Creative          — product images blob access (role assigned in storage module)
//   External-Contractors      — non-prod ACR and App Service access (role assigned in respective modules)
