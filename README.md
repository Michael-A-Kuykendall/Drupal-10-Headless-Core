# Headless Drupal 10 + DDEV Project Stub

## Required Software
- **Docker Desktop** ([Install instructions](https://docs.docker.com/get-docker/))
- **DDEV** ([Install instructions](https://ddev.readthedocs.io/en/stable/#installation))
- **WSL 2** (if on Windows, [Install instructions](https://learn.microsoft.com/en-us/windows/wsl/install))

This repository provides a clean, professional starting point for a headless Drupal 10 project using DDEV for local Dockerized development. It is designed to be easily reusable as a stub for other Drupal/React/GraphQL projects.

## Features
- Composer-based Drupal 10 setup
- DDEV configuration for local development
- Automated setup script (`setup-drupal.sh`) with required site name
- Robust `.gitignore` for Drupal, Composer, DDEV, Node/React, and common artifacts
- Only custom code and configuration are versioned (no core/contrib or vendor files)

## Quick Start
1. Clone this repository and rename the project directory as needed.
2. Run the setup script with your desired site name:
   ```bash
   SITE_NAME="My Project Name" bash setup-drupal.sh
   ```
   The SITE_NAME environment variable is required and must be set.
3. Access your local site at: http://changeme.ddev.site

## To Reuse as a Project Stub
- **Project Name:**
  - Change all references to `changeme` in `.ddev/config.yaml`, `setup-drupal.sh`, and documentation to your new project name.
- **DDEV Hostname:**
  - Update the DDEV project name and hostname in `.ddev/config.yaml`.
- **Drupal Site Name:**
  - Pass your desired site name as the `SITE_NAME` environment variable when running the setup script.
- **Custom Code:**
  - Add your custom modules to `drupal/web/modules/custom/` and custom themes to `drupal/web/themes/custom/`.
- **Configuration:**
  - Export and version your Drupal configuration as needed (e.g., `drupal/config/sync/`).
- **Frontend:**
  - Add your React/Redux frontend in a separate directory (e.g., `/frontend`).

## What to Change for Your Own Project
- Project and site names in DDEV and setup scripts
- Any custom code, themes, or configuration
- README and documentation

## Not Included
- Drupal core, contrib modules/themes, and vendor files (managed by Composer)
- User-generated files (e.g., `sites/default/files/`)

---
For more details, see the comments in `.gitignore` and `setup-drupal.sh`.
