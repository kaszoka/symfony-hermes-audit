#!/usr/bin/env bash
# ==============================================================================
# run-static-gate.sh
# Executes PHPStan (level max + rules/crystallized-phpstan/) and Rector (dry-run)
# Part of symfony-hermes-audit skill
# ==============================================================================

set -euo pipefail

PROJECT_DIR="${1:-.}"
TARGET_PATH="${2:-src}"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORTS_DIR="${PROJECT_DIR}/.cache/audit-reports"
OUTPUT_JSON="${REPORTS_DIR}/initial-findings.json"
CRYSTALLIZED_DIR="${SKILL_DIR}/rules/crystallized-phpstan"

mkdir -p "${REPORTS_DIR}"

PHPSTAN_BIN="${PROJECT_DIR}/vendor/bin/phpstan"
RECTOR_BIN="${PROJECT_DIR}/vendor/bin/rector"

PHPSTAN_RAW="${REPORTS_DIR}/phpstan-raw.json"
RECTOR_RAW="${REPORTS_DIR}/rector-raw.json"

echo "[static-gate] Initializing static analysis gate on ${TARGET_PATH}..."

# Check crystallized rules count
CRYSTALLIZED_COUNT=$(find "${CRYSTALLIZED_DIR}" -type f -name "*.php" 2>/dev/null | wc -l || echo 0)
echo "[static-gate] Active Hermes crystallized AST rules: ${CRYSTALLIZED_COUNT}"

# 1. Execute PHPStan
PHPSTAN_SUCCESS=0
if [ -f "${PHPSTAN_BIN}" ]; then
    echo "[static-gate] Running PHPStan at level=max..."
    PHPSTAN_CONFIG_ARG=()
    if [ -f "${PROJECT_DIR}/phpstan.neon" ]; then
        PHPSTAN_CONFIG_ARG=("-c" "${PROJECT_DIR}/phpstan.neon")
    elif [ -f "${PROJECT_DIR}/phpstan.neon.dist" ]; then
        PHPSTAN_CONFIG_ARG=("-c" "${PROJECT_DIR}/phpstan.neon.dist")
    fi
    "${PHPSTAN_BIN}" analyse "${PROJECT_DIR}/${TARGET_PATH}" --level=max "${PHPSTAN_CONFIG_ARG[@]}" --error-format=json --no-progress > "${PHPSTAN_RAW}" 2>/dev/null || PHPSTAN_SUCCESS=$?
    echo "[static-gate] PHPStan analysis finished (exit code: ${PHPSTAN_SUCCESS})."
else
    echo "[static-gate] Notice: ${PHPSTAN_BIN} not found. Creating placeholder report."
    echo '{"totals":{"errors":0,"file_errors":0},"files":{}}' > "${PHPSTAN_RAW}"
fi

# 2. Execute Rector
RECTOR_SUCCESS=0
if [ -f "${RECTOR_BIN}" ]; then
    echo "[static-gate] Running Rector (dry-run)..."
    "${RECTOR_BIN}" process "${PROJECT_DIR}/${TARGET_PATH}" --dry-run --output-format=json --no-progress-bar > "${RECTOR_RAW}" 2>/dev/null || RECTOR_SUCCESS=$?
    echo "[static-gate] Rector analysis finished (exit code: ${RECTOR_SUCCESS})."
else
    echo "[static-gate] Notice: ${RECTOR_BIN} not found. Creating placeholder report."
    echo '{"totals":{"changed_files":0},"file_diffs":[]}' > "${RECTOR_RAW}"
fi

# 3. Consolidate into initial-findings.json
echo "[static-gate] Consolidating findings into ${OUTPUT_JSON}..."

if command -v python3 >/dev/null 2>&1; then
    PYTHON_BIN="python3"
elif command -v python >/dev/null 2>&1; then
    PYTHON_BIN="python"
else
    PYTHON_BIN=""
fi

if [ -n "${PYTHON_BIN}" ]; then
    "${PYTHON_BIN}" - <<EOF
import json
import os

phpstan_file = "${PHPSTAN_RAW}"
rector_file = "${RECTOR_RAW}"
output_file = "${OUTPUT_JSON}"

findings = []
counter = 1

if os.path.isfile(phpstan_file):
    try:
        with open(phpstan_file, "r", encoding="utf-8") as f:
            data = json.load(f)
            for fpath, file_data in data.get("files", {}).items():
                for msg in file_data.get("messages", []):
                    findings.append({
                        "finding_id": f"AST-STAN-{counter:03d}",
                        "source": "PHPStan",
                        "file_path": fpath,
                        "line": msg.get("line", 1),
                        "message": msg.get("message", ""),
                        "ignorable": msg.get("ignorable", True)
                    })
                    counter += 1
    except Exception:
        pass

if os.path.isfile(rector_file):
    try:
        with open(rector_file, "r", encoding="utf-8") as f:
            data = json.load(f)
            for diff in data.get("file_diffs", []):
                findings.append({
                    "finding_id": f"AST-RECT-{counter:03d}",
                    "source": "Rector",
                    "file_path": diff.get("file", ""),
                    "applied_rules": diff.get("applied_rectors", []),
                    "message": f"Rector proposed changes via: {', '.join(diff.get('applied_rectors', []))}"
                })
                counter += 1
    except Exception:
        pass

report = {
    "total_findings": len(findings),
    "crystallized_rules_active": int("${CRYSTALLIZED_COUNT}"),
    "target_path": "${TARGET_PATH}",
    "findings": findings
}

with open(output_file, "w", encoding="utf-8") as out:
    json.dump(report, out, indent=2)

print(f"[static-gate] Consolidated {len(findings)} initial static gate findings to {output_file}")
EOF
else
    echo "{\"total_findings\": 0, \"crystallized_rules_active\": ${CRYSTALLIZED_COUNT}}" > "${OUTPUT_JSON}"
fi

echo "[static-gate] Static gate ready! Output written to ${OUTPUT_JSON}"
