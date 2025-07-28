# Code Analysis Report
Generated on: Mon Jul 28 23:56:10 UTC 2025
---
## Project Test Metrics

- **PQL Test Cases:** 0
- **Ethics & Bias Test Cases:** 3
- **BDD Scenarios:** 45
- **Total Automated Tests:** 48

---
## Documentation Status

- **Docs Directory Last Modified:** 2025-07-28 23:50:13.798820811 +0000

---
## Orphaned File Analysis

No orphaned or untracked files found in the repository.

---
## TODOs in Scripts

### `scripts/code_analysis.sh`
```
115:    log_info "Scanning for TODO comments in shell scripts..."
118:        echo "## TODOs in Scripts"
123:    # Find all shell scripts, excluding .git, and grep for TODOs
128:        if todo_findings=$(grep -n "TODO" "$script_file" || true); then
144:            echo "No TODO comments found in any shell scripts."
```

No TODO comments found in any shell scripts.
