#!/usr/bin/env bash
# ==============================================================================
# verify-skill-integrity.sh
# Strict Ratchet Safety Guardrail: verifies skill integrity after self-modifications
# Part of symfony-hermes-audit skill
# ==============================================================================

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURES_DIR="${SKILL_DIR}/tests/golden-fixtures"
RULES_FILE="${SKILL_DIR}/rules/symfony-standards-matrix.md"
PROMPTS_FILE="${SKILL_DIR}/prompts/subagents-tribunal.md"

echo "[verify-integrity] Initiating Hermes Strict Ratchet verification..."

FAILURES=0

# 1. Verify Core Non-Negotiable Rules in symfony-standards-matrix.md
check_rule() {
    local pattern="$1"
    local desc="$2"
    if ! grep -qiE "${pattern}" "${RULES_FILE}"; then
        echo "[verify-integrity] FAIL: Core rule missing from matrix: ${desc}"
        FAILURES=$((FAILURES + 1))
    else
        echo "[verify-integrity] PASS: Core rule present: ${desc}"
    fi
}

check_rule "Four-Tier Configuration|Tier 1.*\.env" "Four-Tier Configuration"
check_rule "NoGetInControllerRule|Service Locator" "Prohibition of Service Locator"
check_rule "ServiceEntityRepository" "ServiceEntityRepository Requirement"
check_rule "N\+1|innerJoin.*addSelect" "N+1 Elimination Mandate"
check_rule "Yoda" "Yoda Conditions Standard"
check_rule "NoErrorSilencingRule|operator @" "Error Silencing Prohibition"
check_rule "HERMES EVOLVED PATTERNS" "Hermes Evolved Patterns Section"

# 2. Verify Subagents Tribunal integrity
if ! grep -q "SUBAGENT-ALPHA" "${PROMPTS_FILE}" || \
   ! grep -q "SUBAGENT-BETA" "${PROMPTS_FILE}" || \
   ! grep -q "SUBAGENT-GAMMA" "${PROMPTS_FILE}" || \
   ! grep -q "SUBAGENT-DELTA" "${PROMPTS_FILE}" || \
   ! grep -q "SUBAGENT-OMEGA" "${PROMPTS_FILE}" || \
   ! grep -q "SUBAGENT-EPSILON" "${PROMPTS_FILE}"; then
    echo "[verify-integrity] FAIL: Subagents Tribunal prompt is missing one or more required subagents!"
    FAILURES=$((FAILURES + 1))
else
    echo "[verify-integrity] PASS: All 6 subagents present in tribunal prompt."
fi

# 3. Verify Golden Fixtures
if [ ! -f "${FIXTURES_DIR}/BadController.php" ] || [ ! -f "${FIXTURES_DIR}/GoodController.php" ]; then
    echo "[verify-integrity] FAIL: Golden controller fixtures missing!"
    FAILURES=$((FAILURES + 1))
else
    echo "[verify-integrity] PASS: Golden controller fixtures verified."
fi

if [ ! -f "${FIXTURES_DIR}/BadRepository.php" ] || [ ! -f "${FIXTURES_DIR}/GoodRepository.php" ]; then
    echo "[verify-integrity] FAIL: Golden repository fixtures missing!"
    FAILURES=$((FAILURES + 1))
else
    echo "[verify-integrity] PASS: Golden repository fixtures verified."
fi

if [ "${FAILURES}" -gt 0 ]; then
    echo "[verify-integrity] ERROR: Strict Ratchet check FAILED with ${FAILURES} violation(s)."
    echo "[verify-integrity] Aborting self-evolution mutation. Rollback recommended."
    exit 1
fi

echo "[verify-integrity] SUCCESS: All Strict Ratchet integrity checks PASSED. Skill is structurally sound."
exit 0
