#!/usr/bin/env python3
"""
verify_skill_integrity.py
Strict Ratchet verification script testing core rules, golden fixtures, and tribunal prompts.
Part of symfony-hermes-audit skill.
"""

import os
import re
import sys


def main():
    skill_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    rules_file = os.path.join(skill_dir, "rules", "symfony-standards-matrix.md")
    prompts_file = os.path.join(skill_dir, "prompts", "subagents-tribunal.md")
    fixtures_dir = os.path.join(skill_dir, "tests", "golden-fixtures")

    print("[verify-integrity] Initiating Hermes Strict Ratchet verification...")
    failures = 0

    # 1. Check rules matrix
    if not os.path.isfile(rules_file):
        print(f"[verify-integrity] FAIL: Missing rules matrix at {rules_file}")
        sys.exit(1)

    with open(rules_file, "r", encoding="utf-8", errors="ignore") as f:
        rules_content = f.read()

    mandatory_patterns = [
        (r"Four-Tier Configuration|Tier 1.*\.env", "Four-Tier Configuration"),
        (r"NoGetInControllerRule|Service Locator", "Prohibition of Service Locator"),
        (r"ServiceEntityRepository", "ServiceEntityRepository Requirement"),
        (r"N\+1|innerJoin.*addSelect", "N+1 Elimination Mandate"),
        (r"Yoda", "Yoda Conditions Standard"),
        (r"NoErrorSilencingRule|operator @", "Error Silencing Prohibition"),
        (r"HERMES EVOLVED PATTERNS", "Hermes Evolved Patterns Section"),
    ]

    for pat, desc in mandatory_patterns:
        if not re.search(pat, rules_content, re.IGNORECASE):
            print(f"[verify-integrity] FAIL: Core rule missing from matrix: {desc}")
            failures += 1
        else:
            print(f"[verify-integrity] PASS: Core rule verified: {desc}")

    # 2. Check tribunal prompts
    if not os.path.isfile(prompts_file):
        print(f"[verify-integrity] FAIL: Missing prompts file at {prompts_file}")
        failures += 1
    else:
        with open(prompts_file, "r", encoding="utf-8", errors="ignore") as f:
            prompts_content = f.read()

        subagents = [
            "SUBAGENT-ALPHA",
            "SUBAGENT-BETA",
            "SUBAGENT-GAMMA",
            "SUBAGENT-DELTA",
            "SUBAGENT-OMEGA",
            "SUBAGENT-EPSILON",
        ]
        for sa in subagents:
            if sa not in prompts_content:
                print(f"[verify-integrity] FAIL: Subagent {sa} missing from tribunal prompt!")
                failures += 1
            else:
                print(f"[verify-integrity] PASS: Subagent {sa} present.")

    # 3. Check golden fixtures
    expected_fixtures = [
        "BadController.php",
        "GoodController.php",
        "BadRepository.php",
        "GoodRepository.php",
    ]
    for fix in expected_fixtures:
        p = os.path.join(fixtures_dir, fix)
        if not os.path.isfile(p):
            print(f"[verify-integrity] FAIL: Golden fixture missing: {fix}")
            failures += 1
        else:
            print(f"[verify-integrity] PASS: Golden fixture verified: {fix}")

    if failures > 0:
        print(f"[verify-integrity] ERROR: Strict Ratchet check FAILED with {failures} error(s).", file=sys.stderr)
        sys.exit(1)

    print("[verify-integrity] SUCCESS: All Strict Ratchet checks PASSED! Skill is intact.")
    sys.exit(0)


if __name__ == "__main__":
    main()
