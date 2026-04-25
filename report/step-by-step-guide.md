# WordPress DevSecOps Lab: Step-by-Step Guide

## Step 1: Deploy WordPress Locally

### What to do

Use Docker Compose to define `db` and `wordpress` in [docker/docker-compose.yml](/home/paul/Public/faculta/dev_secops/docker/docker-compose.yml:1).

Start the vulnerable version first:

```bash
./scripts/up-stack.sh vulnerable
./scripts/wait-for-wordpress.sh
./scripts/install-wordpress.sh
```

### Why

- This gives you a reproducible test environment.
- `docker-compose.yml` is the required deployment definition.
- `install-wordpress.sh` matters because WPScan is weak if WordPress is still on the installer page.

### What to explain

- Compose orchestrates multiple containers.
- MariaDB stores WordPress data.
- WordPress connects to the DB through environment variables.

## Step 2: Run WPScan Manually

### What to do

```bash
./scripts/run-wpscan.sh vulnerable baseline-local
```

### Output

- [scans/vulnerable/baseline-local.json](/home/paul/Public/faculta/dev_secops/scans/vulnerable/baseline-local.json:1)
- [scans/vulnerable/baseline-local.txt](/home/paul/Public/faculta/dev_secops/scans/vulnerable/baseline-local.txt:1)

### Why

- This is your "before remediation" evidence.
- It proves the baseline image has weaknesses.

### What you found

- WordPress `6.4.3` insecure
- `xmlrpc.php` enabled
- `readme.html` exposed
- `X-Powered-By` exposed
- full Apache version exposed
- user `admin` enumerable
- outdated default theme

### What to explain

- WPScan is WordPress-specific.
- `--enumerate u,vp,vt` checks users, vulnerable plugins, vulnerable themes.

## Step 3: Build GitHub Actions Workflow to Automate Scanning

### What to do

Use [.github/workflows/scan.yml](/home/paul/Public/faculta/dev_secops/.github/workflows/scan.yml:1).

The workflow already:

- checks out code
- starts Compose
- waits for readiness
- auto-installs WordPress
- runs WPScan
- uploads artifacts
- scans both `vulnerable` and `fixed`

### Why

- This satisfies the automation requirement.
- It turns manual security checks into CI.

### What to explain

- GitHub Actions is your CI runner.
- Each push or manual run can trigger security scanning automatically.
- This is a shift-left control because the scan happens during development, not after release.

## Step 4: Analyze Vulnerabilities

### What to do

Compare:

- [baseline-local.json](/home/paul/Public/faculta/dev_secops/scans/vulnerable/baseline-local.json:1)
- [remediated-local.json](/home/paul/Public/faculta/dev_secops/scans/fixed/remediated-local.json:1)

### How to explain each finding

- Outdated core:
  - Attackers fingerprint version `6.4.3` and match it to public advisories/exploits.
- XML-RPC enabled:
  - Can be abused for brute force or pingback abuse.
- `readme.html` exposed:
  - Helps fingerprint WordPress and versioning context.
- Header leakage:
  - `Apache/2.4.57 (Debian)` and `X-Powered-By: PHP/8.2.17` give attackers environment detail.
- User enumeration:
  - Makes password spraying easier.
- Outdated theme:
  - Old themes may have public issues too.

## Step 5: Apply Patches and Hardening

### What to do

The patching and hardening is in:

- [docker/wordpress/Dockerfile](/home/paul/Public/faculta/dev_secops/docker/wordpress/Dockerfile:1)
- [docker/wordpress/apache-security.conf](/home/paul/Public/faculta/dev_secops/docker/wordpress/apache-security.conf:1)
- [docker/wordpress/php-security.ini](/home/paul/Public/faculta/dev_secops/docker/wordpress/php-security.ini:1)

### What changed

- Core updated from `6.4.3` to `6.9.4`
- Fixed image runs as `www-data`
- Apache moved to container port `8080`
- XML-RPC denied
- `readme.html` and `license.txt` removed or blocked
- default unused plugins removed
- security headers added
- PHP exposure reduced
- Apache version leakage reduced from full version to `Apache`

### Why

- Patching removes known old software risk.
- Hardening reduces attack surface and post-exploitation impact.

### What to explain

- Patching fixes known weaknesses.
- Hardening reduces what attackers can see and use.

## Step 6: Rebuild and Push Fixed Image

### What to do locally

```bash
docker build -f docker/wordpress/Dockerfile --target fixed -t youruser/wordpress-devsecops:latest .
docker login
docker push youruser/wordpress-devsecops:latest
```

### What is already automated

- GHCR push in [scan.yml](/home/paul/Public/faculta/dev_secops/.github/workflows/scan.yml:53)
- Docker Hub push in [scan.yml](/home/paul/Public/faculta/dev_secops/.github/workflows/scan.yml:87)

### What you must configure on GitHub

- `WPSCAN_API_TOKEN`
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

### Why

- The assignment requires a final hardened Docker Hub image.
- Registries make your remediated artifact distributable.

## Step 7: Trigger Re-scan of the Fixed Version

### What to do

```bash
./scripts/rescan-fixed.sh
```

### What it does

- builds and runs vulnerable
- installs WordPress
- scans vulnerable
- tears down
- builds and runs fixed
- installs WordPress
- scans fixed

### Artifacts

- [scans/vulnerable/baseline-local.json](/home/paul/Public/faculta/dev_secops/scans/vulnerable/baseline-local.json:1)
- [scans/fixed/remediated-local.json](/home/paul/Public/faculta/dev_secops/scans/fixed/remediated-local.json:1)

### Why

- This is your semi-automated remediation verification loop.

### What improved in the fixed scan

- core now `6.9.4`
- XML-RPC no longer flagged
- `readme.html` no longer flagged
- no `X-Powered-By`
- `Server` now just `Apache`

### Residual risks to mention

- `wp-cron.php` still reachable
- username enumeration still possible

## Step 8: Produce the PDF Report

### What to do

1. Edit [report/report.md](/home/paul/Public/faculta/dev_secops/report/report.md:1)
2. Replace placeholder GitHub and Docker Hub links
3. Add screenshots or snippets from the scan artifacts
4. Build PDF:

```bash
./scripts/build-report.sh
```

### Output

- `report/report.pdf`

### Why

- The markdown file is your report source.
- The script uses a Dockerized Pandoc image, so no local Pandoc install is needed.

## What to Put in the Report

### 1. Environment Setup

- Docker Compose setup
- vulnerable and fixed image design
- challenge: WPScan initially hit installer mode
- solution: automate WordPress installation

### 2. Findings Overview

- old WordPress core
- XML-RPC
- readme exposure
- header disclosure
- user enumeration
- outdated theme

### 3. Remediation Steps

- core update
- non-root runtime
- Apache and PHP hardening
- sensitive file blocking
- before and after WPScan evidence

### 4. Fixed Image Build

- GitHub repo link
- Docker Hub link

### 5. Tooling Justification

- Docker for reproducibility
- WPScan for WordPress-specific security checks
- GitHub Actions for CI automation
- registries for publishing the remediated image

### 6. DevSecOps Strategy

- commit -> build -> deploy -> scan -> fix -> rebuild -> rescan
- that is shift-left because security runs during development workflow

## Deliverable Checklist

- GitHub repo: done
- `docker-compose.yml`: done
- `scan.yml`: done
- `scans/` artifacts: done
- hardened image files: done
- commit history: done
- Docker Hub image: you still need to publish with your account
- PDF report: you still need to finalize markdown and run the build
