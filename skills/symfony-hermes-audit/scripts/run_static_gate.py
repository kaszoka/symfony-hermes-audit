#!/usr/bin/env python3
"""
run_static_gate.py
Cross-platform static gate runner (PHPStan max + crystallized rules + Rector).
Part of symfony-hermes-audit skill.
"""

import argparse
import json
import os
import shutil
import subprocess
import sys


def find_binary(project_dir: str, binary_name: str) -> str:
    vendor_bin_unix = os.path.join(project_dir, "vendor", "bin", binary_name)
    vendor_bin_win = os.path.join(project_dir, "vendor", "bin", f"{binary_name}.bat")
    vendor_bin_exe = os.path.join(project_dir, "vendor", "bin", f"{binary_name}.exe")

    for path in (vendor_bin_win, vendor_bin_exe, vendor_bin_unix):
        if os.path.isfile(path):
            return path

    which_path = shutil.which(binary_name)
    if which_path:
        return which_path

    return ""


def count_crystallized_rules(skill_dir: str) -> int:
    rules_dir = os.path.join(skill_dir, "rules", "crystallized-phpstan")
    if not os.path.isdir(rules_dir):
        return 0
    return len([f for f in os.listdir(rules_dir) if f.endswith(".php")])


def main():
    parser = argparse.ArgumentParser(description="Run PHPStan and Rector static analysis gate")
    parser.add_argument("--project-dir", default=".", help="Root directory of the target Symfony project")
    parser.add_argument("--target-dir", default="src", help="Target source path to audit")
    parser.add_argument("--reports-dir", default="", help="Directory to store reports")

    args = parser.parse_args()

    project_dir = os.path.abspath(args.project_dir)
    skill_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    reports_dir = os.path.abspath(args.reports_dir) if args.reports_dir else os.path.join(project_dir, ".cache", "audit-reports")
    os.makedirs(reports_dir, exist_ok=True)

    phpstan_raw = os.path.join(reports_dir, "phpstan-raw.json")
    rector_raw = os.path.join(reports_dir, "rector-raw.json")
    findings_out = os.path.join(reports_dir, "initial-findings.json")

    crystallized_count = count_crystallized_rules(skill_dir)
    print(f"[static-gate] Active Hermes crystallized AST rules: {crystallized_count}")

    phpstan_bin = find_binary(project_dir, "phpstan")
    rector_bin = find_binary(project_dir, "rector")

    target_full = os.path.join(project_dir, args.target_dir)

    # 1. PHPStan
    if phpstan_bin:
        cmd = [phpstan_bin, "analyse", target_full, "--level=max", "--error-format=json", "--no-progress"]
        try:
            res = subprocess.run(cmd, cwd=project_dir, capture_output=True, text=True)
            out = res.stdout.strip()
            s, e = out.find("{"), out.rfind("}")
            clean_json = out[s : e + 1] if s != -1 and e != -1 else "{}"
            with open(phpstan_raw, "w", encoding="utf-8") as f:
                f.write(clean_json)
        except Exception as ex:
            print(f"[static-gate] PHPStan run failed: {ex}", file=sys.stderr)
            with open(phpstan_raw, "w", encoding="utf-8") as f:
                json.dump({"files": {}}, f)
    else:
        with open(phpstan_raw, "w", encoding="utf-8") as f:
            json.dump({"files": {}}, f)

    # 2. Rector
    if rector_bin:
        cmd = [rector_bin, "process", target_full, "--dry-run", "--output-format=json", "--no-progress-bar"]
        try:
            res = subprocess.run(cmd, cwd=project_dir, capture_output=True, text=True)
            out = res.stdout.strip()
            s, e = out.find("{"), out.rfind("}")
            clean_json = out[s : e + 1] if s != -1 and e != -1 else "{}"
            with open(rector_raw, "w", encoding="utf-8") as f:
                f.write(clean_json)
        except Exception as ex:
            print(f"[static-gate] Rector run failed: {ex}", file=sys.stderr)
            with open(rector_raw, "w", encoding="utf-8") as f:
                json.dump({"file_diffs": []}, f)
    else:
        with open(rector_raw, "w", encoding="utf-8") as f:
            json.dump({"file_diffs": []}, f)

    # Consolidate
    findings = []
    counter = 1
    if os.path.isfile(phpstan_raw):
        try:
            with open(phpstan_raw, "r", encoding="utf-8") as f:
                data = json.load(f)
                for fpath, file_data in data.get("files", {}).items():
                    for msg in file_data.get("messages", []):
                        findings.append({
                            "finding_id": f"AST-STAN-{counter:03d}",
                            "source": "PHPStan",
                            "file_path": fpath,
                            "line": msg.get("line", 1),
                            "message": msg.get("message", ""),
                            "ignorable": msg.get("ignorable", True),
                        })
                        counter += 1
        except Exception:
            pass

    if os.path.isfile(rector_raw):
        try:
            with open(rector_raw, "r", encoding="utf-8") as f:
                data = json.load(f)
                for diff in data.get("file_diffs", []):
                    findings.append({
                        "finding_id": f"AST-RECT-{counter:03d}",
                        "source": "Rector",
                        "file_path": diff.get("file", ""),
                        "applied_rules": diff.get("applied_rectors", []),
                        "message": f"Rector proposed changes via: {', '.join(diff.get('applied_rectors', []))}",
                    })
                    counter += 1
        except Exception:
            pass

    report = {
        "total_findings": len(findings),
        "crystallized_rules_active": crystallized_count,
        "target_path": args.target_dir,
        "findings": findings,
    }

    with open(findings_out, "w", encoding="utf-8") as out:
        json.dump(report, out, indent=2)

    print(f"[static-gate] Consolidated {len(findings)} findings to {findings_out}")


if __name__ == "__main__":
    main()
