<div align="center">

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

**Autonomous Symfony (6.4 LTS, 7.x, 8.x) Code Audit & Refactoring Skill**  
*Adversarial Subagent Tribunal • Hermes Closed-Loop Self-Evolution • Billion-Context (`acp-kernel`)*

[![Author](https://img.shields.io/badge/author-kaszoka-000000?style=flat-square&logo=github&logoColor=white)](https://github.com/kaszoka)
[![Repository](https://img.shields.io/badge/repo-symfony--hermes--audit-000000?style=flat-square&logo=git&logoColor=white)](https://github.com/kaszoka/symfony-hermes-audit)
[![Symfony](https://img.shields.io/badge/Symfony-6.4%20%7C%207.x%20%7C%208.x-000000?style=flat-square&logo=symfony&logoColor=white)](https://symfony.com/doc)
[![PHPStan](https://img.shields.io/badge/PHPStan-Level%20Max-000000?style=flat-square)](https://phpstan.org/)
[![License](https://img.shields.io/badge/license-MIT-000000?style=flat-square)](./LICENSE)

</div>

---

## Instant Installation

### Method 1: Via Universal Skills Manager (Recommended)
Installs natively across 30+ AI coding harnesses with a single command:

```bash
npx skills add kaszoka/symfony-hermes-audit
```

### Method 2: Interactive Multi-Harness TUI Installer
Launches the monochrome CLI wizard with multi-harness selection, automatic rule bridging, and local Symfony `.rst` documentation synchronization:

```bash
npx github:kaszoka/symfony-hermes-audit
```
*(or clone the repository and run `npm run setup`)*

---

## Supported AI Harnesses

| Harness | Target Location | Bridge Configuration |
| :--- | :--- | :--- |
| **Universal / Pi / Billion-Context** | `.agents/skills/symfony-hermes-audit` | Native `SKILL.md` discovery & `acp-kernel` tools |
| **Claude Code** | `.claude/skills/symfony-hermes-audit` | Native subagent delegation & `/symfony-hermes-audit` |
| **OpenCode** | `.opencode/skills/symfony-hermes-audit` | Native skill & `parentID` context inheritance |
| **Cursor** | `.cursor/skills/symfony-hermes-audit` | Automatic `.cursor/rules/symfony-hermes-audit.mdc` bridge |
| **Windsurf** | `.windsurf/skills/symfony-hermes-audit` | Automatic `.windsurf/rules/symfony-hermes-audit.md` bridge |
| **Cline / Roo Code** | `.roo/skills/symfony-hermes-audit` | `.clinerules` & Roo mode discovery |
| **GitHub Copilot / Codex** | `.github/skills/symfony-hermes-audit` | Repository workspace skill |
| **Antigravity** | `~/.gemini/config/skills/symfony-hermes-audit` | Automatic global skill registration |

---

## Why This Exists & How the Architecture Works

Single-agent LLM code reviews fail on complex Symfony codebases due to confirmation bias, sycophancy, web-search hallucinations, and rapid context window degradation. **`symfony-hermes-audit`** replaces single-pass prompting with a deterministic, self-evolving 6-phase engineering pipeline:

```text
+-------------------------------------------------------------------------------------------------------+
|                                    SYMFONY-HERMES-AUDIT PIPELINE                                      |
+-------------------------------------------------------------------------------------------------------+
| [Phase 0] Offline Setup & Version Sync   --> Read composer.lock -> shallow clone symfony-docs (.rst)  |
| [Phase 1] Static Gate + Crystallized AST --> Run PHPStan (level max + Hermes rules) & Rector dry-run  |
| [Phase 2] Parallel Adversarial Attack    --> Subagent-Alpha (Arch/DI) + Subagent-Beta (ORM/Sec)       |
| [Phase 3] Counter-Proof & Rebuttal       --> Subagent-Gamma (Challenger) + Subagent-Delta (AST check) |
| [Phase 4] Synthesis, Refactor & Reports  --> Subagent-Omega (Judge) -> audit-report.md & patch.diff   |
| [Phase 5] Hermes Self-Evolution & Fold   --> Subagent-Epsilon -> AST Crystallize -> Ratchet -> Fold   |
+-------------------------------------------------------------------------------------------------------+
```

### The 4 Architectural Pillars

1. **Local Offline RST Knowledge Base (`.cache/symfony-docs/`)**:
   Reads your exact Symfony version from `composer.lock` and performs a shallow clone (`git clone --depth 1 --branch <X.Y> https://github.com/symfony/symfony-docs.git`). **Zero web lookups** are permitted during audits, completely eliminating outdated Symfony 2/3/4 advice and HTML parsing overhead.
2. **Zero-Bypass Protocol & Mechanical Static Gate**:
   Strictly prohibits partial file scans, placeholder comments (`// ... rest of code`), and error suppression (`@phpstan-ignore`, `@psalm-suppress`, or PHP's `@` operator). Enforces the **Dual-Evidence Mandate**: every reported defect must cite both (A) exact file line numbers and (B) a verbatim quote from a local `.rst` file or a static analysis rule ID. Includes hard circuit breakers (max 3 iterations without progress or 5 iterations without consensus).
3. **Billion-Context Token Economy (`acp-kernel`)**:
   Implements Model-Driven Incremental Hierarchical Compression (**The Fold**: `compress`, `decompress`, `search_context`, `acp_status`). Completed module audits, raw AST dumps, and settled subagent debates (`mXXXXX..mYYYYY`) are folded into compact Tier-1 summary blocks (185–500 tokens), keeping the active raw working zone around **~50,000 tokens** with a **>94% prefix KV-cache hit rate**. Subagents spawn in clean windows via read-only `derivedFrom` lineage links (~600 tokens/turn overhead) and query parent history on demand without payload duplication.
4. **Hermes Closed-Loop Self-Evolution Engine ($O(\text{LLM}) \rightarrow O(\text{AST})$)**:
   Before context compression occurs in Phase 5, the skill reflects on the tribunal's friction points:
   * **Procedural Prompt Patching**: If `hermes-alpha` or `hermes-beta` raised a false positive rejected by `hermes-delta`, `hermes-epsilon` updates `memory/tribunal-telemetry.json` and patches the offending agent's `[HERMES-LEARNED-HEURISTICS]` block in `prompts/subagents-tribunal.md`.
   * **AST Crystallization**: When the tribunal catches a structural anti-pattern via LLM debate, `hermes-epsilon` writes a new custom PHPStan rule into `rules/crystallized-phpstan/`. On every subsequent audit, that defect is caught in **Phase 1 for 0 LLM tokens**.
   * **Living Standards Matrix**: Newly discovered Symfony edge cases are appended as anonymized *Bad vs. Good* pairs in `rules/symfony-standards-matrix.md`.
   * **Strict Ratchet Guardrail**: Self-modification is strictly additive. After any mutation, `scripts/verify-skill-integrity.sh` tests the skill against `tests/golden-fixtures/`. If detection accuracy drops below 100%, changes are automatically rolled back.

---

## Subagent Tribunal Roster

All subagents communicate via strict JSON contracts and are forbidden from agreeing without verifiable `.rst` or AST proof:

| Subagent ID | Role | Adversarial Mandate & Responsibility |
| :--- | :--- | :--- |
| **`Subagent-Alpha`** (`hermes-alpha`) | *Architecture, DI & Coding Standards Prosecutor* | Assumes every class violates Dependency Injection, mixes configuration tiers, or breaks `contributing/code/standards.rst`. |
| **`Subagent-Beta`** (`hermes-beta`) | *Doctrine ORM & OWASP Security Inquisitor* | Hunts $N+1$ queries in loops/Twig/`EntityType`, `findAll()` memory leaks, missing `ServiceEntityRepository`, XSS, and Open Redirects. |
| **`Subagent-Gamma`** (`hermes-gamma`) | *Devil's Advocate & Pragmatism Guardian* | **Mandatory Rebuttal**: Challenges Alpha and Beta findings. Proves when a flagged issue is a false positive, already handled by `EXTRA_LAZY`, incompatible with `composer.lock`, or over-engineered. |
| **`Subagent-Delta`** (`hermes-delta`) | *Mechanical AST & Local RST Verifier* | Zero-opinion fact-checker. Verifies byte-for-byte that cited `.rst` quotes exist in `.cache/symfony-docs/`, cross-checks `phpstan`/`rector` JSON output, and marks findings with `crystallizable_to_ast: true/false`. |
| **`Subagent-Omega`** (`hermes-omega`) | *Chief Judge, Refactoring Architect & Patch Synthesizer* | Arbitrates verified findings, resolves circuit-breaker deadlocks, writes production-ready `strict_types=1` refactored PHP code, and generates persistent deliverables. |
| **`Subagent-Epsilon`** (`hermes-epsilon`) | *Hermes Evolution Engineer* | Updates subagent telemetry, patches subagent prompts, crystallizes recurring defects into custom PHPStan rules, runs the integrity ratchet, and triggers the `billion-context` Fold. |

---

## Enforced Symfony Standards (6.4 LTS / 7.x / 8.x)

| Domain | Enforced Rules & Best Practices |
| :--- | :--- |
| **4-Tier Configuration & DI** | `.env` strictly for infrastructure; **Symfony Secrets** for credentials; `config/services.yaml` `app.*` (`snake_case`) for application behavior; `public const` (`SCREAMING_SNAKE_CASE`) for rarely changing options. Private services with autowiring. Zero `$this->get()` or `$this->getParameter()` in controllers. Never mix `__construct()` and `#[Required]`. No `#[Required]` inside traits. |
| **Controllers, DTOs & Mapping** | Thin, `final` single-action `__invoke()` controllers. No constructor in abstract base controllers. Declarative request mapping via `#[MapRequestPayload]`, `#[MapQueryString]`, `#[MapQueryParameter]`, `#[MapUploadedFile]`, and `#[MapEntity]` with explicit `validationGroups` and status codes. DTO-to-Entity transformation via `ObjectMapperInterface`. |
| **Routing, Forms & Events** | Full explicit paths in `#[Route]` (no hidden YAML prefixes). Event listeners must implement `EventSubscriberInterface` using `::class` constants. Dedicated PHP form classes, submit buttons in Twig, purpose-based translation keys (`label.username`, never `edit_form.label`). |
| **Doctrine ORM & $N+1$ Prevention** | PHP attributes mapping (`#[ORM\...]`). All repositories must extend `ServiceEntityRepository` (zero `$em->getRepository()`). Zero `findAll()` followed by PHP array filtering. Explicit `innerJoin`/`leftJoin` + `addSelect` for iterated relations; `EXTRA_LAZY` for large collections (`count()`, `contains()`, `slice()`). Valid root entity return in `EntityType` `query_builder`. |
| **Symfony Coding Standards** | Mandatory `declare(strict_types=1);`, 120-char line limit, trailing commas in multiline arrays/constructors. **Yoda conditions** (`null === $user`). No `else`/`elseif`/`break` after `return`/`throw`. Blank line before `return`. Exceptions formatted via `sprintf()`, capitalized, ending with `.`, double quotes `"`, using `get_debug_type($obj)` instead of `$obj::class`. Strict class member ordering (`properties` $\rightarrow$ `__construct` $\rightarrow$ `public` $\rightarrow$ `protected` $\rightarrow$ `private`). Precise PHPDoc array shapes (`list<User>`) with `null` last in union types. |
| **OWASP Security** | Zero `@` error silencing. Mandatory `HtmlSanitizerInterface` before Twig `|raw`. Open Redirect prevention on `Request` parameters. Authorization via `#[IsGranted]` and `Voter` classes. |

---

## Code Audit Preview (Bad vs. Good)

**Current Offending Code (Flagged by `hermes-alpha` & `hermes-beta`):**
```php
<?php
namespace App\Controller;

use App\Entity\ProductReview;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;

class BadProductReviewController extends AbstractController
{
    public function __construct(private EntityManagerInterface $em) {}

    #[Route('/api/products/{id}/reviews', methods: ['POST'])]
    public function create(int $id, Request $request): JsonResponse
    {
        $maxRating = $this->getParameter('max_rating'); // Service Locator + missing 'app.' prefix
        $data = $request->request->all();               // Manual payload extraction

        if ($data['rating'] == null || $data['rating'] > $maxRating) { // Non-Yoda, loose comparison
            throw new \InvalidArgumentException('Field `rating` is invalid for ' . $request::class);
        } else { // Redundant else after throw
            $product = $this->em->getRepository(\App\Entity\Product::class)->find($id);
            $review = new ProductReview();
            $review->setComment((string) @$data['comment']); // @ error silencing
            $this->em->persist($review);
            $this->em->flush();
            return new JsonResponse(['status' => 'ok'], 201);
        }
    }
}
```

**Refactored Code (Synthesized by `hermes-omega`):**
```php
<?php

declare(strict_types=1);

namespace App\Controller;

use App\Dto\CreateProductReviewDto;
use App\Entity\Product;
use App\Entity\ProductReview;
use App\Repository\ProductReviewRepository;
use Symfony\Bridge\Doctrine\Attribute\MapEntity;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Attribute\MapRequestPayload;
use Symfony\Component\ObjectMapper\ObjectMapperInterface;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/api/products/{id}/reviews', name: 'api_product_review_create', methods: ['POST'])]
final class CreateProductReviewController extends AbstractController
{
    public function __construct(
        private readonly ProductReviewRepository $reviewRepository,
        private readonly ObjectMapperInterface $objectMapper,
    ) {
    }

    public function __invoke(
        #[MapEntity] Product $product,
        #[MapRequestPayload(
            acceptFormat: 'json',
            validationGroups: ['create'],
            validationFailedStatusCode: Response::HTTP_UNPROCESSABLE_ENTITY,
        )] CreateProductReviewDto $reviewDto,
    ): JsonResponse {
        if (!$product->isReviewable()) {
            throw new \DomainException(sprintf('Product of type "%s" cannot be reviewed.', get_debug_type($product)));
        }

        /** @var ProductReview $review */
        $review = $this->objectMapper->map($reviewDto, ProductReview::class);
        $review->assignToProduct($product);

        $this->reviewRepository->save($review, true);

        return $this->json(
            ['id' => $review->getId()],
            Response::HTTP_CREATED,
        );
    }
}
```

---

## Persistent Audit Deliverables

At the conclusion of Phase 4, the tribunal automatically persists three structured artifacts inside `.cache/audit-reports/` in your audited project:

* **`audit-report.md`**: Detailed human-readable engineering report containing:
  - Defect location (file path, exact line range, severity: `CRITICAL`, `MAJOR`, `MINOR`).
  - Legal Grounding (verbatim `.rst` citation or static AST rule ID).
  - Debate Trajectory (Prosecutor claim $\rightarrow$ Devil's Advocate challenge $\rightarrow$ Mechanical AST proof).
  - Side-by-side **Current Offending Code (Bad)** vs. **Refactored Code (Good - Symfony Standard)**.
* **`audit-patch.diff`**: Ready-to-apply Git diff patch. Inspect and apply instantly:
  ```bash
  git apply .cache/audit-reports/audit-patch.diff
  ```
* **`final-verdict.json`**: Machine-readable JSON ledger of all verified defects and tribunal telemetry for automated CI/CD gating.

---

## Repository Structure

```text
symfony-hermes-audit/
├── package.json                           # Multi-harness CLI & npx skills configuration
├── README.md                              # Documentation
├── LICENSE                                # MIT License
├── bin/
│   └── cli.mjs                            # Interactive monochrome TUI installer (@clack/prompts)
└── skills/
    └── symfony-hermes-audit/
        ├── SKILL.md                       # Primary Orchestrator manifest & Billion-Context rules
        ├── prompts/
        │   └── subagents-tribunal.md      # Adversarial Tribunal prompts & Hermes heuristic blocks
        ├── rules/
        │   ├── symfony-standards-matrix.md# Complete Symfony 6.4/7.x/8.x Bad vs. Good reference
        │   └── crystallized-phpstan/      # Auto-generated 0-token PHPStan rules from Hermes loop
        ├── memory/
        │   ├── evolution-ledger.jsonl     # Append-only log of skill self-modifications
        │   └── tribunal-telemetry.json    # Accuracy & false-positive tracking per subagent
        ├── scripts/
        │   ├── banner.sh                  # Monochrome terminal ASCII header
        │   ├── sync-symfony-docs.sh       # Shallow-clones matching symfony-docs (.rst) branch
        │   ├── run-static-gate.sh         # Runs PHPStan + Rector + Crystallized AST rules
        │   └── verify-skill-integrity.sh  # Strict-ratchet regression test after self-mutation
        └── tests/
            └── golden-fixtures/           # Canonical Bad/Good Symfony files for integrity checks
                ├── BadController.php
                └── GoodController.php
```

---

## Running the Audit

Trigger the audit directly inside your AI coding assistant:

```text
/symfony-hermes-audit
```

Target a specific controller, service, or Git diff:

```text
/symfony-hermes-audit src/Controller/OrderController.php
/symfony-hermes-audit --git-diff
```

Or invoke naturally in chat:
> *"Audit this Symfony codebase using symfony-hermes-audit."*

---

## License

MIT © 2026 **[kaszoka](https://github.com/kaszoka)** — [github.com/kaszoka/symfony-hermes-audit](https://github.com/kaszoka/symfony-hermes-audit)