# Automated Vulnerability Discovery & Remediation Pipeline

## 1. Environment Setup

### Objective

Build a reproducible DevSecOps workflow that deploys WordPress in containers, scans it with WPScan, remediates identified weaknesses, rebuilds the image, and verifies the fixes by rescanning.

### Components Used

- Docker and Docker Compose
- Official WordPress image as the starting point
- MariaDB 11.4 as the database
- WPScan for WordPress-focused scanning
- GitHub Actions for CI automation
- GitHub Container Registry and Docker Hub for image distribution

### Setup Steps

1. Initialized a Git repository and created a clean project structure.
2. Built a Docker Compose stack containing:
   - WordPress
   - MariaDB
3. Created a multi-stage Dockerfile with two targets:
   - `vulnerable`
   - `fixed`
4. Added local helper scripts to:
   - start the stack
   - stop the stack
   - wait for readiness
   - complete the initial WordPress installation
   - run WPScan
   - execute a vulnerable-to-fixed rescan loop
5. Added a GitHub Actions workflow to automate scanning and image publication.

### Challenges Encountered

- WPScan vulnerability enrichment depends on an API token.
- A realistic before/after comparison needs both a vulnerable baseline and a fixed target.
- Hardening had to remain compatible with WordPress runtime behavior.
- WPScan returns weak evidence when WordPress is still in installer mode.

### Solutions

- Made the WPScan API token optional so the pipeline still runs without it.
- Created two image profiles in one Dockerfile for a controlled baseline and remediated comparison.
- Applied practical hardening that does not break the basic site startup flow.
- Automated the initial setup page submission so scans run against a configured application.

## 2. Findings Overview

### High-Level Findings

- The vulnerable profile runs an older pinned WordPress core version.
- Sensitive public files such as `readme.html` and `license.txt` can disclose information.
- XML-RPC exposure increases brute-force and abuse opportunities.
- Username and version enumeration are possible through WordPress-specific reconnaissance.
- The fixed profile reduces post-exploitation impact by dropping root privileges.

### Risk Assessment

- **Outdated core**: High. Publicly known vulnerabilities can be mapped to the detected version.
- **XML-RPC exposure**: Medium. Commonly abused for authentication attacks and amplified requests.
- **Information disclosure**: Medium. Makes targeted exploitation easier.
- **Root runtime**: Medium to High. Raises the impact of a web compromise inside the container.

### Potential Exploitation Paths

- An attacker identifies the WordPress version through passive fingerprints, then checks WPScan or public advisories for version-specific vulnerabilities.
- XML-RPC can be abused for credential attacks using batched authentication attempts.
- Enumerated usernames can be paired with password spraying.
- If a vulnerable plugin or theme is later installed, the same WPScan workflow can immediately detect it and block promotion.

## 3. Remediation Steps

### Patching and Updating

- Upgraded WordPress core from `6.4.3-php8.2-apache` to `6.9.4-php8.2-apache`.
- Kept MariaDB on an explicit supported tag instead of an unpinned floating database image.
- Removed default unused plugins from the fixed image to reduce attack surface.
- No third-party plugins are installed in this lab image. If a vulnerable plugin is added later, the same WPScan workflow enumerates plugins and stores the evidence in the scan artifacts.
- Updated the default theme baseline by using the newer WordPress image and removing stale disclosure files that helped fingerprint the vulnerable build.

### Hardening Measures

- Ran the fixed image as `www-data` instead of `root`.
- Moved Apache to port `8080` inside the container and published it on host port `8090` so non-root execution is practical without colliding with other local labs.
- Added Apache hardening:
  - `ServerSignature Off`
  - `ServerTokens Prod`
  - `TraceEnable Off`
  - security headers
  - blocked access to `xmlrpc.php`, `readme.html`, `license.txt`, and `wp-config.php`
  - disabled directory indexing
- Added PHP hardening:
  - `expose_php = Off`
  - `display_errors = Off`
  - `allow_url_include = Off`
  - secure session cookie defaults
- Added WordPress config hardening:
  - disabled plugin/theme file editing
  - disabled in-dashboard file modifications

### Before/After Evidence

- Baseline artifacts: `scans/vulnerable/`
- Fixed artifacts: `scans/fixed/`
- GitHub Actions also uploads the same artifacts per run.
- Latest verified workflow run: [GitHub Actions run 24940247993](https://github.com/WhiteStar03/dev_secops/actions/runs/24940247993)
- Baseline scan evidence:
  - WordPress version `6.4.3`
  - version status `insecure`
  - WPScan findings included `headers`, `xmlrpc`, `readme`, and `wp_cron`
- Fixed scan evidence:
  - WordPress version `6.9.4`
  - version status `latest`
  - `xmlrpc` and `readme` were no longer reported
  - remaining observations were `headers` and `wp_cron`
- Residual fixed-scan observations: `wp-cron.php` may still be detected and username enumeration can still expose the initial admin username. These are documented as residual risks rather than false claims of complete security.

## 4. Fixed Image Build

### GitHub Repository

- `https://github.com/WhiteStar03/dev_secops`

### Docker Hub Image

- `https://hub.docker.com/r/skyv3il/wordpress-devsecops`

### Registries

- GHCR:
  - `ghcr.io/whitestar03/wordpress-devsecops:latest`
- Docker Hub:
  - `skyv3il/wordpress-devsecops:latest`

## 5. Tooling Justification

### Docker

Docker makes the environment reproducible, portable, and easy to reset after each scan/remediation cycle.

### Docker Compose

Compose defines the multi-container application in a single file and makes local reproduction simple.

### WPScan

WPScan is specialized for WordPress and provides focused reconnaissance and vulnerability insights that generic container scanners would miss.

### GitHub Actions

GitHub Actions automates the scan/build/push cycle on each change and keeps security checks close to development activity.

### GHCR and Docker Hub

Publishing the remediated image to registries makes the fixed artifact easy to distribute and reuse.

## 6. DevSecOps Strategy

This workflow demonstrates shift-left security because security checks are placed directly into the software delivery lifecycle:

- developers commit changes
- CI builds the application image
- the image is deployed in an ephemeral environment
- WPScan performs automated assessment
- artifacts are preserved for review
- the fixed image is built and published only after the pipeline succeeds

This reduces the time between introducing a weakness and detecting it. It also produces audit-friendly evidence for remediation and verification.

## 7. Conclusion

The project shows how WordPress-specific scanning can be integrated into a practical DevSecOps pipeline. The result is a repeatable loop: deploy, scan, patch, harden, rebuild, rescan, and publish a safer image.
