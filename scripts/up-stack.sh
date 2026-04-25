#!/usr/bin/env bash
set -euo pipefail

PROFILE="${1:-fixed}"
PROJECT_NAME="${2:-devsecops-${PROFILE}}"
ENV_FILE="docker/env/${PROFILE}.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}" >&2
  exit 1
fi

docker compose \
  -f docker/docker-compose.yml \
  --env-file "${ENV_FILE}" \
  -p "${PROJECT_NAME}" \
  up -d --build
