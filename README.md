```text
  ███████╗██╗   ██╗███╗   ███╗███████╗ ██████╗ ███╗   ██╗██╗   ██╗
  ██╔════╝╚██╗ ██╔╝████╗ ████║██╔════╝██╔═══██╗████╗  ██║╚██╗ ██╔╝
  ███████╗ ╚████╔╝ ██╔████╔██║█████╗  ██║   ██║██╔██╗ ██║ ╚████╔╝ 
  ╚════██║  ╚██╔╝  ██║╚██╔╝██║██╔══╝  ██║   ██║██║╚██╗██║  ╚██╔╝  
  ███████║   ██║   ██║ ╚═╝ ██║██║     ╚██████╔╝██║ ╚████║   ██║   
  ╚══════╝   ╚═╝   ╚═╝     ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   
  ██╗  ██╗███████╗██████╗ ███╗   ███╗███████╗███████╗
  ██║  ██║██╔════╝██╔══██╗████╗ ████║██╔════╝██╔════╝
  ███████║█████╗  ██████╔╝██╔████╔██║█████╗  ███████╗
  ██╔══██║██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══╝  ╚════██║
  ██║  ██║███████╗██║  ██║██║ ╚═╝ ██║███████╗███████║
  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝
```

# `kaszoka/symfony-hermes-audit`

> **Autonomous Symfony (6.4 LTS, 7.x, 8.x) Code Audit & Refactoring Skill**  
> *Adversarial Subagent Tribunal • Hermes Closed-Loop Self-Evolution • Billion-Context (`acp-kernel`)*  
> Author: **[kaszoka](https://github.com/kaszoka)** | Repository: **[github.com/kaszoka/symfony-hermes-audit](https://github.com/kaszoka/symfony-hermes-audit)**

---

## ⚡ Instant Installation

### Method 1: Via Universal Skills Manager (Recommended)
Installs natively across 30+ AI coding harnesses:
```bash
npx skills add kaszoka/symfony-hermes-audit
```

### Method 2: Interactive Multi-Harness TUI Installer
Launches the monochrome CLI wizard with harness selection and automated docs sync:
```bash
npx github:kaszoka/symfony-hermes-audit
```
*(or clone and run `npm run setup`)*

---

## 🏛️ Architectural Pillars

```
+-------------------------------------------------------------------------------------------------------+
|                                  SYMFONY-HERMES-AUDIT PIPELINE                                        |
+-------------------------------------------------------------------------------------------------------+
| [Phase 0] Offline Setup & Version Sync   --> Read composer.lock -> shallow clone symfony-docs (.rst)  |
| [Phase 1] Static Gate + Crystallized AST --> Run PHPStan (level max + Hermes rules) & Rector dry-run   |
| [Phase 2] Parallel Adversarial Attack    --> Subagent-Alpha (Arch/DI) + Subagent-Beta (ORM/Sec)       |
| [Phase 3] Counter-Proof & Rebuttal       --> Subagent-Gamma (Challenger) + Subagent-Delta (AST check) |
| [Phase 4] Synthesis, Refactor & Reports  --> Subagent-Omega (Judge) -> audit-report.md & patch.diff    |
| [Phase 5] Hermes Self-Evolution & Fold   --> Subagent-Epsilon -> AST Crystallize -> Ratchet -> Fold   |
+-------------------------------------------------------------------------------------------------------+
```

1. **Local Offline RST Knowledge Base**:
   Grounds every verdict in an official shallow clone (`git clone --depth 1 --branch <X.Y> https://github.com/symfony/symfony-docs.git`) stored in `.cache/symfony-docs/`. **Zero web lookups** during audit, eliminating context poisoning and hallucinations.
2. **Zero-Bypass Protocol & Mechanical Static Gate**:
   Prohibits code omission, error suppression (`@phpstan-ignore`, `@`), and partial file inspection. Enforces the **Dual-Evidence Mandate**: every defect requires exact file line numbers AND a verbatim quote from local `.rst` docs or an AST rule.
3. **Billion-Context Token Economy (`acp-kernel`)**:
   Maintains active context around ~50,000 tokens with $>94\%$ KV-cache prefix hits via **The Fold** (`compress`, `decompress`, `search_context`, `acp_status`). Subagents run in clean windows via low-overhead `derivedFrom` lineage delegation (~600 tokens/turn).
4. **Hermes Closed-Loop Self-Evolution Engine**:
   Reflects on tribunal debates, measures subagent accuracy in `memory/tribunal-telemetry.json`, writes new crystallized PHPStan AST rules into `rules/crystallized-phpstan/` (catching defects at **0 LLM tokens** in Phase 1), enriches `rules/symfony-standards-matrix.md`, and validates mutations with the **Strict Ratchet Law** (`scripts/verify-skill-integrity.sh`).

---

## 🎯 Supported AI Harnesses

| Harness | Target Location | Bridge Configuration |
| :--- | :--- | :--- |
| **Universal / Pi / Billion-Context** | `.agents/skills/symfony-hermes-audit` | Native `SKILL.md` discovery |
| **Claude Code** | `.claude/skills/symfony-hermes-audit` | Native subagent delegation |
| **OpenCode** | `.opencode/skills/symfony-hermes-audit` | `parentID` context inheritance |
| **Cursor** | `.cursor/skills/symfony-hermes-audit` | Automatic `.cursor/rules/symfony-hermes-audit.mdc` bridge |
| **Windsurf** | `.windsurf/skills/symfony-hermes-audit` | Automatic `.windsurf/rules/symfony-hermes-audit.md` bridge |
| **Cline / Roo Code** | `.roo/skills/symfony-hermes-audit` | `.clinerules` discovery |
| **GitHub Copilot / Codex** | `.github/skills/symfony-hermes-audit` | Repository workspace skill |
| **Antigravity** | `~/.gemini/config/skills/symfony-hermes-audit` | Automatic global skill registration |

---

## 📁 Persistent Audit Deliverables

At the conclusion of Phase 4, the tribunal automatically persists three structured files inside `.cache/audit-reports/` in your audited project:

* 📄 **`audit-report.md`**: Detailed human-readable report listing:
  * What is broken (file, line range, severity: `CRITICAL`, `MAJOR`, `MINOR`).
  * Legal Grounding (exact `.rst` citation or AST rule).
  * Debate Trajectory (prosecution claim vs. defense challenge vs. mechanical proof).
  * **Current Offending Code (Bad Code)**.
  * **Refactored Code (Good Code - Symfony Standard)**.
* 🛠️ **`audit-patch.diff`**: Ready-to-apply Git diff patch. Inspect and apply instantly:
  ```bash
  git apply .cache/audit-reports/audit-patch.diff
  ```
* 📊 **`final-verdict.json`**: Machine-readable JSON ledger of all verified defects for automated CI/CD gating.

---

## ⚖️ Subagent Tribunal Roster

* 🔴 **Subagent-Alpha (`hermes-alpha`)**: *Architecture, DI & Coding Standards Prosecutor*
* 🔴 **Subagent-Beta (`hermes-beta`)**: *Doctrine ORM ($N+1$ query elimination) & OWASP Inquisitor*
* 🛡️ **Subagent-Gamma (`hermes-gamma`)**: *Devil's Advocate & Pragmatism Guardian (Anti-Overengineering)*
* ⚖️ **Subagent-Delta (`hermes-delta`)**: *Mechanical AST & Local RST Fact-Checking Verifier*
* 📜 **Subagent-Omega (`hermes-omega`)**: *Chief Judge, Refactoring Architect & Patch Synthesizer*
* 🧬 **Subagent-Epsilon (`hermes-epsilon`)**: *Hermes Evolution Engineer (Self-Learning & AST Crystallizer)*

---

## 🚀 Running the Audit

Trigger the audit in your AI coding assistant:
```text
/symfony-hermes-audit
```
or invoke naturally:
> *"Audit this Symfony codebase using symfony-hermes-audit."*

---

## 📄 License

MIT © 2026 [kaszoka](https://github.com/kaszoka)
