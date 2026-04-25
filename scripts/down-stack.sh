#!/usr/bin/env bash
set -euo pipefail

PROFILE="${1:-fixed}"
PROJECT_NAME="${2:-devsecops-${PROFILE}}"
ENV_FILE="docker/env/${PROFILE}.env"

docker compose \
  -f docker/docker-compose.yml \
  --env-file "${ENV_FILE}" \
  -p "${PROJECT_NAME}" \
  down -v --remove-orphans
