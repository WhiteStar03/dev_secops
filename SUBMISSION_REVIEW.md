# Final Submission Review

This file maps every lab requirement to the exact implementation in this repository and explains what to say in the final report or presentation.

## Current Status

- GitHub repository: ready
- Docker Compose deployment: ready
- Automated WPScan GitHub Actions workflow: ready
- Vulnerable and fixed scan artifacts: ready
- Fixed/hardened image build files: ready
- GitHub Container Registry image: ready
- PDF report generation in GitHub Actions: ready
- Docker Hub image: pending your Docker Hub account secrets

Verified successful workflow run:

```text
https://github.com/WhiteStar03/dev_secops/actions/runs/24928685514
```

GitHub Container Registry image:

```text
ghcr.io/whitestar03/wordpress-devsecops:latest
```

## Requirement Review

| Requirement | Status | Evidence |
| --- | --- | --- |
| Deploy WordPress using Docker Compose | Ready | `docker/docker-compose.yml` |
| Automate WPScan in GitHub Actions | Ready | `.github/workflows/scan.yml` |
| Store WPScan artifacts | Ready | `scans/vulnerable/`, `scans/fixed/`, workflow artifacts |
| Analyze vulnerabilities | Ready | `report/report.md`, `SUBMISSION_REVIEW.md` |
| Patch WordPress core | Ready | `docker/wordpress/Dockerfile` updates fixed image to WordPress `6.9.4` |
| Patch plugins/themes | Ready with explanation | No third-party plugins are installed; unused defaults are removed; theme baseline comes from updated official image |
| Harden image | Ready | non-root runtime, Apache hardening, PHP hardening, blocked sensitive paths |
| Rebuild fixed image | Ready | GitHub Actions builds fixed target |
| Push to GHCR | Ready | latest workflow run pushed `ghcr.io/whitestar03/wordpress-devsecops:latest` |
| Push to Docker Hub | Pending account setup | Add Docker Hub secrets, rerun workflow |
| Trigger rescan after remediation | Ready | workflow scans both vulnerable and fixed profiles; `scripts/rescan-fixed.sh` does the same locally |
| Produce PDF report | Ready | `scripts/build-report.sh`; workflow artifact named `report-pdf-<run-id>` |

## What Was Built

The project creates a controlled vulnerable WordPress baseline and a remediated WordPress image. The pipeline starts the WordPress stack, completes installation automatically, runs WPScan, stores results, builds the fixed image, pushes it to registries, and generates a PDF report artifact.

You can explain it like this:

```text
I built a DevSecOps pipeline for a containerized WordPress deployment. The pipeline deploys WordPress and MariaDB with Docker Compose, scans the application with WPScan in GitHub Actions, stores before-and-after scan artifacts, rebuilds a hardened fixed image, publishes the fixed image to a registry, and produces a PDF report artifact.
```

## Findings Explanation

The vulnerable scan demonstrates these issues:

- Outdated WordPress core: WordPress `6.4.3` is detected as insecure. Attackers can fingerprint the version and map it to public advisories.
- XML-RPC exposure: `xmlrpc.php` can support brute-force and abuse scenarios when left exposed.
- Readme/version disclosure: `readme.html` helps attackers identify the WordPress installation and version context.
- Header disclosure: Apache/PHP details expose technology information that helps targeted attacks.
- Username enumeration: discovered usernames can be used in password spraying.
- Root container runtime: if the web application is compromised, running as root increases impact inside the container.

The fixed scan shows improvement:

- WordPress is updated to `6.9.4`.
- XML-RPC is blocked.
- `readme.html` and `license.txt` are removed or blocked.
- `X-Powered-By` is removed.
- Apache version leakage is reduced.
- The fixed image runs as `www-data`, not root.

Residual observations to mention honestly:

- `wp-cron.php` may still be detected by WPScan.
- Username enumeration can still expose the initial admin username.
- Without `WPSCAN_API_TOKEN`, WPScan has limited vulnerability database enrichment.

These residual items do not break the lab. They show that remediation is iterative, which is the point of DevSecOps.

## Remediation Explanation

The remediation has two parts: patching and hardening.

Patching:

- The vulnerable image uses `wordpress:6.4.3-php8.2-apache`.
- The fixed image uses `wordpress:6.9.4-php8.2-apache`.
- Default unused plugins are removed.
- No third-party plugin is installed, so there is no separate third-party plugin patch to apply.

Hardening:

- The container runs as `www-data`.
- Apache listens on unprivileged container port `8080`.
- Apache blocks sensitive files and XML-RPC.
- Apache disables `ServerSignature`, reduces `ServerTokens`, disables TRACE, and adds security headers.
- PHP disables risky exposure settings such as `expose_php`, `display_errors`, and `allow_url_include`.
- WordPress config disables file editing and file modifications from the dashboard.

## GitHub Actions Explanation

The workflow is in:

```text
.github/workflows/scan.yml
```

It runs on push, pull request, and manual dispatch.

The workflow jobs are:

- `scan`: runs twice through a matrix, once for `vulnerable` and once for `fixed`.
- `publish-ghcr`: builds and pushes the fixed image to GitHub Container Registry.
- `publish-dockerhub`: builds and pushes to Docker Hub only when Docker Hub secrets exist.
- `build-report`: builds `report/report.pdf` and uploads it as an artifact.

This satisfies the automation requirement because every push can rebuild, deploy, scan, archive results, and publish the fixed image.

## Docker Hub Final Step

Docker Hub cannot be completed automatically until you add your account secrets.

Do this:

1. Create a Docker Hub repository named `wordpress-devsecops`.
2. Create a Docker Hub access token with read/write permission.
3. In GitHub, open `Settings -> Secrets and variables -> Actions`.
4. Add `DOCKERHUB_USERNAME`.
5. Add `DOCKERHUB_TOKEN`.
6. Rerun the workflow on `main`.
7. Confirm `latest` exists at `https://hub.docker.com/r/<your-user>/wordpress-devsecops`.
8. Replace Docker Hub placeholders in `report/report.md`.
9. Rerun the workflow or run `./scripts/build-report.sh` to regenerate the final PDF.

## PDF Report Step

The report source is:

```text
report/report.md
```

Build locally:

```bash
./scripts/build-report.sh
```

Or download from GitHub Actions:

```text
Actions -> latest successful run -> Artifacts -> report-pdf-...
```

For final submission, the PDF should include:

- GitHub repository link
- latest successful GitHub Actions run link
- GHCR image link
- Docker Hub image link after you publish it
- before/after scan evidence
- explanation of vulnerabilities and remediation

## Final Answer If Asked "Is It Ready?"

Use this:

```text
The GitHub repository, Docker Compose deployment, automated WPScan workflow, scan artifacts, hardened image build, GHCR publishing, and PDF generation are ready. The only remaining required deliverable is publishing the final hardened image to Docker Hub, which requires adding my Docker Hub username and access token as GitHub Actions secrets and rerunning the workflow.
```
