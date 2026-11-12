#!/usr/bin/env python3
"""
sync_symfony_docs.py
Cross-platform synchronization and indexing of official Symfony documentation (.rst).
Part of symfony-hermes-audit skill.
"""

import argparse
import json
import os
import re
import subprocess
import sys


CORE_TOPICS = {
    "best_practices.rst": "ARCHITECTURE_BEST_PRACTICES",
    "configuration.rst": "CONFIGURATION_DI",
    "controller.rst": "CONTROLLERS_ROUTING",
    "doctrine.rst": "DOCTRINE_DATABASE",
    "entity.rst": "DOCTRINE_ENTITIES",
    "forms.rst": "FORMS_VALIDATION",
    "validation.rst": "VALIDATION_RULES",
    "security.rst": "SECURITY_OWASP",
    "standards.rst": "CODING_STANDARDS",
}


def detect_symfony_version(project_dir: str) -> str:
    composer_lock_path = os.path.join(project_dir, "composer.lock")
    if not os.path.isfile(composer_lock_path):
        return ""

    try:
        with open(composer_lock_path, "r", encoding="utf-8") as f:
            data = json.load(f)
            packages = data.get("packages", []) + data.get("packages-dev", [])
            for pkg in packages:
                name = pkg.get("name", "")
                if name in ("symfony/framework-bundle", "symfony/symfony"):
                    version_raw = pkg.get("version", "")
                    match = re.search(r"v?([0-9]+\.[0-9]+)", version_raw)
                    if match:
                        return match.group(1)
    except Exception as e:
        print(f"[sync-symfony-docs] Warning: failed to parse composer.lock: {e}", file=sys.stderr)

    return ""


def sync_git_docs(cache_dir: str, branch: str) -> bool:
    os.makedirs(os.path.dirname(os.path.abspath(cache_dir)), exist_ok=True)
    git_dir = os.path.join(cache_dir, ".git")
    repo_url = "https://github.com/symfony/symfony-docs.git"

    if os.path.isdir(git_dir):
        print(f"[sync-symfony-docs] Existing repository detected at {cache_dir}. Fetching branch {branch}...")
        try:
            subprocess.run(["git", "fetch", "--depth", "1", "origin", branch], cwd=cache_dir, check=True, capture_output=True)
            subprocess.run(["git", "checkout", "-f", "FETCH_HEAD"], cwd=cache_dir, check=True, capture_output=True)
            return True
        except subprocess.CalledProcessError:
            subprocess.run(["git", "checkout", "master"], cwd=cache_dir, check=False)
            return True
    else:
        print(f"[sync-symfony-docs] Shallow cloning {repo_url} (branch {branch}) into {cache_dir}...")
        try:
            subprocess.run(["git", "clone", "--depth", "1", "--branch", branch, repo_url, cache_dir], check=True)
            return True
        except subprocess.CalledProcessError:
            try:
                subprocess.run(["git", "clone", "--depth", "1", "--branch", "7.4", repo_url, cache_dir], check=True)
                return True
            except subprocess.CalledProcessError:
                subprocess.run(["git", "clone", "--depth", "1", repo_url, cache_dir], check=True)
                return True


def index_rst_files(cache_dir: str, branch: str, output_index: str) -> dict:
    index_data = {
        "symfony_branch": branch,
        "indexed_files": {},
        "rule_mapping": {},
    }

    for root, _, files in os.walk(cache_dir):
        if ".git" in root:
            continue
        for filename in files:
            if not filename.endswith(".rst"):
                continue

            full_path = os.path.join(root, filename)
            rel_path = os.path.relpath(full_path, cache_dir).replace("\\", "/")
            basename = os.path.basename(filename)
            topic = CORE_TOPICS.get(basename, "GENERAL")

            index_data["indexed_files"][rel_path] = {"topic": topic}
            if topic != "GENERAL":
                index_data["rule_mapping"][topic] = rel_path

    os.makedirs(os.path.dirname(os.path.abspath(output_index)), exist_ok=True)
    with open(output_index, "w", encoding="utf-8") as out:
        json.dump(index_data, out, indent=2)

    return index_data


def main():
    parser = argparse.ArgumentParser(description="Synchronize and index local Symfony documentation (.rst)")
    parser.add_argument("--project-dir", default=".", help="Root directory of the target Symfony project")
    parser.add_argument("--branch", default="", help="Specific Symfony docs branch to check out")
    parser.add_argument("--cache-dir", default="", help="Target directory for cloning symfony-docs")
    parser.add_argument("--output-index", default="", help="Path for generated docs-index.json")

    args = parser.parse_args()

    project_dir = os.path.abspath(args.project_dir)
    cache_dir = os.path.abspath(args.cache_dir) if args.cache_dir else os.path.join(project_dir, ".cache", "symfony-docs")
    output_index = os.path.abspath(args.output_index) if args.output_index else os.path.join(cache_dir, "docs-index.json")

    detected_branch = args.branch
    if not detected_branch:
        detected_branch = detect_symfony_version(project_dir) or "7.4"

    sync_git_docs(cache_dir, detected_branch)
    index_data = index_rst_files(cache_dir, detected_branch, output_index)
    print(f"[sync-symfony-docs] Indexed {len(index_data['indexed_files'])} .rst files to {output_index}")


if __name__ == "__main__":
    main()
