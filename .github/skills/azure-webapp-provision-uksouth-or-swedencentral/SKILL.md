---
name: azure-webapp-provision-uksouth-or-swedencentral
description: >
  Provisions an Azure Web App (App Service) using Azure CLI, but ONLY in UK South (uksouth) or Sweden Central (swedencentral).
  The skill accepts user-supplied parameters, asks for any missing required parameters, validates/normalizes the region via a bundled script,
  and refuses any region outside the allowlist.
license: MIT
---

# Azure Web App Provisioning (Allowed regions only: UK South / Sweden Central)

## Purpose
Help the user provision an Azure Web App (App Service) using Azure CLI with a strict regional allowlist:
- Allowed: **UK South (`uksouth`)**
- Allowed: **Sweden Central (`swedencentral`)**

If the user asks for any other region, you must refuse and offer only these two choices.

---

## Hard guardrails (must follow)
1. **Region allowlist is mandatory.** Only `uksouth` or `swedencentral` are permitted.
2. **Validate and normalize region using the bundled script** before issuing any create commands.
3. **Accept all parameters** the user provides (don’t ignore them).
4. **Ask for any missing required parameters** before running provisioning commands.
5. **Be explicit about what will be created** (resource group, plan, web app, optional config/deploy).

---

## Inputs / Parameters

### Required (collect if missing)
- **region**: must be `uksouth` or `swedencentral` (user may say “UK South” or “Sweden Central”)
- **resourceGroupName**
- **appName** (must be globally unique)
- **planName**
- **sku** (e.g., B1/S1/P1v3 — user choice)
- **osType**: `linux` or `windows`
- **runtime** (e.g., `NODE|20-lts`, `DOTNET|8.0`, `PYTHON|3.11`) OR container parameters if deploying container

### Optional (use when provided / requested)
- **subscription** (id/name)
- **tags** (key=value)
- **httpsOnly** (true/false)
- **identity** (system-assigned or user-assigned)
- **appSettings** (key=value)
- **deploymentSource**: `none` | `zip` | `github` | `local-git` | `container`
- **repoUrl**, **branch** (github deploy)
- **zipPath** (zip deploy)
- **containerImage**, registry creds (container)

---

## Workflow

### Step 0 — Preflight
1. Confirm Azure CLI login context (e.g., `az account show`). If not logged in, instruct `az login`.
2. If user provides **subscription**, set it:
   - `az account set --subscription "<subscription>"`

### Step 1 — Collect missing required parameters
Before you output any provisioning commands, ensure you have:
- region, resourceGroupName, appName, planName, sku, osType, runtime (or container choice)

If any are missing, ask for them as a short checklist.

### Step 2 — Validate + normalize region (hard gate)
1. Run the bundled validator script and capture its output:
   ```bash
   bash scripts/validate-region.sh "<region>"
