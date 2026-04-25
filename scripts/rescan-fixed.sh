#!/usr/bin/env bash
set -euo pipefail

./scripts/down-stack.sh vulnerable >/dev/null 2>&1 || true
./scripts/down-stack.sh fixed >/dev/null 2>&1 || true

./scripts/up-stack.sh vulnerable
./scripts/wait-for-wordpress.sh
./scripts/install-wordpress.sh
./scripts/run-wpscan.sh vulnerable baseline-local
./scripts/down-stack.sh vulnerable

./scripts/up-stack.sh fixed
./scripts/wait-for-wordpress.sh
./scripts/install-wordpress.sh
./scripts/run-wpscan.sh fixed remediated-local

echo "Rescan loop completed."
echo "Baseline artifacts: scans/vulnerable/"
echo "Fixed artifacts: scans/fixed/"
