# Scan Artifacts

This directory stores WPScan evidence for the lab.

- `scans/vulnerable/`: baseline evidence collected from the intentionally vulnerable image
- `scans/fixed/`: evidence collected after patching and hardening

Each scan saves:

- `*.json`: machine-readable WPScan output
- `*.txt`: terminal-friendly WPScan output captured during execution

For GitHub Actions runs, the same files are also uploaded as workflow artifacts.
