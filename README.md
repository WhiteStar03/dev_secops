# Automated Vulnerability Discovery & Remediation Pipeline

This repository implements a small DevSecOps lab for a containerized WordPress deployment. It gives you:

- a reproducible vulnerable baseline image
- a remediated and hardened WordPress image
- local helper scripts for deploy, scan, rescan, and report generation
- a GitHub Actions workflow that scans both profiles and publishes the fixed image

## Repository Layout

- `docker/docker-compose.yml`: local deployment definition
- `docker/wordpress/Dockerfile`: multi-stage WordPress image with `vulnerable` and `fixed` targets
- `docker/wordpress/apache-security.conf`: Apache hardening rules for the fixed image
- `docker/wordpress/php-security.ini`: PHP hardening settings for the fixed image
- `docker/env/*.env`: profile-specific environment files
- `scripts/*.sh`: helper scripts for starting the stack, waiting for readiness, scanning, rescanning, and building the report
- `.github/workflows/scan.yml`: CI pipeline for WPScan, artifact upload, and fixed image publication
- `scans/`: WPScan JSON and text artifacts
- `report/report.md`: report source you can export to PDF
- `SUBMISSION_REVIEW.md`: final requirement checklist and presentation explanation

## What This Lab Demonstrates

1. Deploy a containerized WordPress stack with Docker Compose.
2. Scan the running application with WPScan.
3. Compare a controlled vulnerable profile against a hardened profile.
4. Patch WordPress core by moving from an older pinned image to a current pinned image.
5. Apply basic hardening:
   - run the web tier as a non-root user
   - use a pinned MariaDB version
   - remove default exposure files
   - deny access to `xmlrpc.php`, `readme.html`, `license.txt`, and `wp-config.php`
   - disable Apache signature leakage
   - add security headers
   - disable risky PHP exposure settings
   - disable in-dashboard plugin/theme file editing
6. Publish the fixed image to GHCR and Docker Hub from GitHub Actions.
7. Keep scan results as artifacts for before/after evidence.

The container itself listens on `8080`, while the host-facing default in this repo is `8090` to avoid common local conflicts. You can change it in `docker/env/*.env`.
The local and CI flows also auto-complete the initial WordPress installation so WPScan targets a configured site instead of the installer page.

## Quick Start

### 1. Start the vulnerable profile

```bash
./scripts/up-stack.sh vulnerable
./scripts/install-wordpress.sh
./scripts/run-wpscan.sh vulnerable baseline-local
```

This gives you the "before remediation" evidence.

### 2. Start the fixed profile

```bash
./scripts/down-stack.sh vulnerable
./scripts/up-stack.sh fixed
./scripts/install-wordpress.sh
./scripts/run-wpscan.sh fixed fixed-local
```

This gives you the "after remediation" evidence.

### 3. Run the full local loop

```bash
./scripts/rescan-fixed.sh
```

That script performs the full vulnerable -> scan -> fixed -> rescan cycle.

### 4. Stop everything

```bash
./scripts/down-stack.sh fixed
```

## GitHub Actions Setup

Create these repository secrets before running `.github/workflows/scan.yml`:

- `WPSCAN_API_TOKEN`: optional but recommended; enables vulnerability enrichment from the WPScan database
- `DOCKERHUB_USERNAME`: required only if you want Docker Hub publishing
- `DOCKERHUB_TOKEN`: required only if you want Docker Hub publishing

The workflow will:

1. build and boot the vulnerable profile
2. scan it with WPScan
3. upload scan artifacts
4. build and boot the fixed profile
5. scan it with WPScan
6. upload scan artifacts
7. build and push the fixed image to GHCR
8. optionally push the fixed image to Docker Hub if secrets are present

## How To Explain This In Your Presentation

### Environment Setup

- Docker Compose orchestrates WordPress and MariaDB.
- A multi-stage Dockerfile provides two targets:
  - `vulnerable`: older WordPress core, minimal hardening
  - `fixed`: updated WordPress core plus hardening
- Helper scripts remove repetitive manual work.
- `install-wordpress.sh` completes the initial setup automatically so the scanner sees a real site state.

### Findings Overview

Typical issues the vulnerable profile demonstrates:

- outdated WordPress core version
- information disclosure through public files like `readme.html`
- XML-RPC exposure that can support brute-force or abuse scenarios
- username/version enumeration opportunities
- root-running container process, which raises impact if the container is compromised
- external `wp-cron.php` exposure, which WPScan reports by default and which you can discuss as an operational hardening candidate

### Exploitation Paths

- If the site exposes an old WordPress version, an attacker can map that version to public advisories and exploit code.
- If XML-RPC is exposed, an attacker can use multi-call authentication abuse for password spraying or brute force.
- If usernames are enumerable, credential attacks become easier.
- If the web process runs as root, a web compromise has a larger blast radius inside the container.

### Remediation

- upgrade WordPress core from the older baseline to a current pinned image
- rebuild on a current official WordPress image
- run Apache as `www-data` instead of root
- add Apache and PHP hardening settings
- block sensitive paths
- remove default exposure files and unused default plugins
- disable in-dashboard file editing/modification

## Notes About WPScan Results

Without `WPSCAN_API_TOKEN`, WPScan still detects versions and configuration weaknesses, but vulnerability database enrichment is limited. For a stronger report, use a token and cite the exact CVEs or WPScan advisory IDs shown in the JSON artifact.

## PDF Report

Edit `report/report.md` if you need to change wording or evidence, then generate a PDF:

```bash
./scripts/build-report.sh
```

The script uses a `pandoc/latex` container so you do not need a local Pandoc installation.
