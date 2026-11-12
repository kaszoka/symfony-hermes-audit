#!/usr/bin/env bash
# ==============================================================================
# sync-symfony-docs.sh
# Synchronizes official Symfony documentation (.rst) locally matching composer.lock
# Part of symfony-hermes-audit skill
# ==============================================================================

set -euo pipefail

PROJECT_DIR="${1:-.}"
CACHE_DIR="${PROJECT_DIR}/.cache/symfony-docs"
INDEX_FILE="${CACHE_DIR}/docs-index.json"
DEFAULT_BRANCH="7.4"

echo "[sync-symfony-docs] Starting offline documentation sync..."

DETECTED_VERSION=""
if [ -f "${PROJECT_DIR}/composer.lock" ]; then
    echo "[sync-symfony-docs] Reading composer.lock from ${PROJECT_DIR}..."
    DETECTED_VERSION=$(grep -A 5 '"name": "symfony/framework-bundle"' "${PROJECT_DIR}/composer.lock" | grep '"version":' | head -n 1 | sed -E 's/.*"version": "v?([0-9]+\.[0-9]+).*/\1/' || true)
    
    if [ -z "${DETECTED_VERSION}" ]; then
        DETECTED_VERSION=$(grep -A 5 '"name": "symfony/symfony"' "${PROJECT_DIR}/composer.lock" | grep '"version":' | head -n 1 | sed -E 's/.*"version": "v?([0-9]+\.[0-9]+).*/\1/' || true)
    fi
fi

if [ -n "${DETECTED_VERSION}" ]; then
    TARGET_BRANCH="${DETECTED_VERSION}"
    echo "[sync-symfony-docs] Detected Symfony version from composer.lock: ${TARGET_BRANCH}"
else
    TARGET_BRANCH="${2:-${DEFAULT_BRANCH}}"
    echo "[sync-symfony-docs] No composer.lock found or version unparsed. Defaulting to branch: ${TARGET_BRANCH}"
fi

mkdir -p "$(dirname "${CACHE_DIR}")"

if [ -d "${CACHE_DIR}/.git" ]; then
    echo "[sync-symfony-docs] Existing repository found at ${CACHE_DIR}. Fetching branch ${TARGET_BRANCH}..."
    (
        cd "${CACHE_DIR}"
        git fetch --depth 1 origin "${TARGET_BRANCH}" || git fetch --depth 1 origin master
        git checkout -f FETCH_HEAD || git checkout "${TARGET_BRANCH}" || true
    )
else
    echo "[sync-symfony-docs] Shallow cloning symfony/symfony-docs (branch: ${TARGET_BRANCH}) into ${CACHE_DIR}..."
    rm -rf "${CACHE_DIR}"
    git clone --depth 1 --branch "${TARGET_BRANCH}" https://github.com/symfony/symfony-docs.git "${CACHE_DIR}" || {
        echo "[sync-symfony-docs] Branch ${TARGET_BRANCH} failed, falling back to 7.4..."
        git clone --depth 1 --branch "7.4" https://github.com/symfony/symfony-docs.git "${CACHE_DIR}" || \
        git clone --depth 1 https://github.com/symfony/symfony-docs.git "${CACHE_DIR}"
    }
fi

echo "[sync-symfony-docs] Indexing .rst files to ${INDEX_FILE}..."

if command -v python3 >/dev/null 2>&1; then
    PYTHON_BIN="python3"
elif command -v python >/dev/null 2>&1; then
    PYTHON_BIN="python"
else
    PYTHON_BIN=""
fi

if [ -n "${PYTHON_BIN}" ]; then
    "${PYTHON_BIN}" - <<EOF
import os
import json
import re

cache_dir = "${CACHE_DIR}"
index_file = "${INDEX_FILE}"
index_data = {
    "symfony_branch": "${TARGET_BRANCH}",
    "indexed_files": {},
    "rule_mapping": {}
}

core_topics = {
    "best_practices.rst": "ARCHITECTURE_BEST_PRACTICES",
    "configuration.rst": "CONFIGURATION_DI",
    "controller.rst": "CONTROLLERS_ROUTING",
    "doctrine.rst": "DOCTRINE_DATABASE",
    "entity.rst": "DOCTRINE_ENTITIES",
    "forms.rst": "FORMS_VALIDATION",
    "validation.rst": "VALIDATION_RULES",
    "security.rst": "SECURITY_OWASP",
    "standards.rst": "CODING_STANDARDS"
}

for root, _, files in os.walk(cache_dir):
    if ".git" in root:
        continue
    for f in files:
        if f.endswith(".rst"):
            rel_path = os.path.relpath(os.path.join(root, f), cache_dir).replace("\\\\", "/")
            basename = os.path.basename(rel_path)
            topic = core_topics.get(basename, "GENERAL")
            index_data["indexed_files"][rel_path] = {"topic": topic}
            if topic != "GENERAL":
                index_data["rule_mapping"][topic] = rel_path

with open(index_file, "w", encoding="utf-8") as out:
    json.dump(index_data, out, indent=2)

print(f"[sync-symfony-docs] Successfully indexed {len(index_data['indexed_files'])} .rst documents.")
EOF
else
    echo "{\"symfony_branch\": \"${TARGET_BRANCH}\"}" > "${INDEX_FILE}"
fi

echo "[sync-symfony-docs] Documentation sync complete! Offline knowledge base ready at ${CACHE_DIR}"
