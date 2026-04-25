# Next Steps After GitHub Push

The repository is already pushed here:

```text
https://github.com/WhiteStar03/dev_secops
```

The GitHub Actions workflow already ran successfully here:

```text
https://github.com/WhiteStar03/dev_secops/actions/runs/24928685514
```

The fixed image was pushed to GitHub Container Registry:

```text
ghcr.io/whitestar03/wordpress-devsecops:latest
```

## 1. Create the Docker Hub Repository

Go to Docker Hub:

```text
https://hub.docker.com/
```

Create a new repository named:

```text
wordpress-devsecops
```

If your Docker Hub username is `youruser`, the final image link will be:

```text
https://hub.docker.com/r/youruser/wordpress-devsecops
```

The image name will be:

```text
youruser/wordpress-devsecops:latest
```

## 2. Create a Docker Hub Access Token

In Docker Hub:

```text
Account Settings -> Personal access tokens -> Generate new token
```

Create a token with read/write permissions.

Keep this token ready. You will put it into GitHub as `DOCKERHUB_TOKEN`.

## 3. Add GitHub Actions Secrets

Open your GitHub repository:

```text
https://github.com/WhiteStar03/dev_secops
```

Go to:

```text
Settings -> Secrets and variables -> Actions -> New repository secret
```

Add these secrets:

```text
DOCKERHUB_USERNAME
```

Value:

```text
your Docker Hub username
```

```text
DOCKERHUB_TOKEN
```

Value:

```text
your Docker Hub access token
```

Optional but recommended:

```text
WPSCAN_API_TOKEN
```

Value:

```text
your WPScan API token
```

You can get a WPScan API token from:

```text
https://wpscan.com/
```

## 4. Rerun the GitHub Actions Workflow

Go to:

```text
GitHub repo -> Actions -> WordPress WPScan DevSecOps Loop -> Run workflow
```

Run it on the `main` branch.

Expected result:

- vulnerable WordPress scan runs
- fixed WordPress scan runs
- scan artifacts are uploaded
- PDF report is uploaded as an artifact
- fixed image is pushed to GHCR
- fixed image is pushed to Docker Hub

## 5. Check the Docker Hub Image

After the workflow finishes, open:

```text
https://hub.docker.com/r/youruser/wordpress-devsecops
```

Confirm that the `latest` tag exists.

This satisfies the required Docker Hub deliverable.

## 6. Update the Report Links

Edit:

```text
report/report.md
```

Update the Docker Hub link:

```text
https://hub.docker.com/r/youruser/wordpress-devsecops
```

Update the Docker Hub image name:

```text
youruser/wordpress-devsecops:latest
```

The GitHub link is already correct:

```text
https://github.com/WhiteStar03/dev_secops
```

The GHCR link is already correct:

```text
ghcr.io/whitestar03/wordpress-devsecops:latest
```

## 7. Generate the Final PDF Report

You can generate it locally:

```bash
./scripts/build-report.sh
```

Output:

```text
report/report.pdf
```

You can also download the PDF from GitHub Actions:

```text
Actions -> latest successful run -> Artifacts -> report-pdf-...
```

## 8. Final Submission Checklist

Before submitting, confirm you have:

- GitHub repository link
- successful GitHub Actions workflow run
- WPScan artifacts under `scans/`
- PDF report
- Docker Hub image link
- GHCR image link
- clear commit history
- final review checklist in `SUBMISSION_REVIEW.md`

## 9. What to Say if Asked What You Built

Use this short explanation:

```text
I built a DevSecOps pipeline for WordPress. It deploys WordPress and MariaDB using Docker Compose, scans the site with WPScan in GitHub Actions, stores scan artifacts, applies remediation through a hardened fixed image, rescans the fixed version, builds a PDF report, and publishes the fixed image to container registries.
```
