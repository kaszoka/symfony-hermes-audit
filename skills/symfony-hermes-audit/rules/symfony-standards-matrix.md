# Symfony Standards & Anti-Patterns Matrix (Symfony 6.4 LTS, 7.x, 8.x)

This document is the living knowledge matrix for `symfony-hermes-audit`. It contains both core canonical standards and dynamically evolved rules captured by the Hermes self-evolution loop.

---

## 1. Application Architecture & Configuration Hierarchy

Reference documentation: `best_practices.rst`, `configuration.rst`

### 1.1. Prohibition of Custom Application Bundles
* **Rule**: Do not create custom bundles (classes extending `Symfony\Component\HttpKernel\Bundle\Bundle`) to organize business logic inside an application. All application domain logic must reside inside `src/`.
* **Rationale**: Custom bundles introduce artificial abstraction layers and unnecessary dependency overhead. Bundles are strictly intended for reusable, open-source third-party packages.
* **Citation**: `best_practices.rst` (Section: "Organizing Your Application Logic")

### 1.2. Four-Tier Configuration Separation Doctrine
Every configuration value in a Symfony application must belong to exactly one of four distinct tiers:

| Tier | Mechanism | Intended Scope & Rules | Prohibited Anti-Patterns |
| :--- | :--- | :--- | :--- |
| **Tier 1** | `.env` / Environment Variables | Infrastructure that changes per deployment machine (e.g., `DATABASE_URL`, `MAILER_DSN`, `REDIS_URL`). | Using `$_ENV` or `.env` to toggle business features or application logic. |
| **Tier 2** | Symfony Secrets (`bin/console secrets:*`) | Sensitive credentials, API keys, private certificates, encryption tokens. | Committing plain-text secrets into `.env` or `services.yaml`. |
| **Tier 3** | Container Parameters (`config/services.yaml`) | Application behavior options (e.g., notification sender emails, pagination sizes, feature toggles). Must use `app.` prefix and short `snake_case` (e.g., `app.admin_email`, `app.contents_dir`). | Defining parameters without `app.` prefix; building complex `TreeBuilder` configs for internal app logic. |
| **Tier 4** | PHP Class Constants (`public const`) | Immutable domain constants and rarely changing options (e.g., `Post::DEFAULT_PAGE_SIZE = 10`). | Registering rarely changing values as dynamic container parameters or env vars. |

### 1.3. Dependency Injection & Service Container Purity
* **Private Services by Default**: Services must be configured with `public: false`, `autowire: true`, and `autoconfigure: true`.
* **Prohibition of Service Locator Pattern**:
  - `NoGetInControllerRule`: Calling `$this->get(...)` or `$container->get(...)` in controllers or services is strictly prohibited. All dependencies must be injected via constructor property promotion or action method arguments.
  - `NoControllerGetParameterRule`: Calling `$this->getParameter(...)` inside a controller is prohibited. Inject specific parameters via `#[Autowire(param: 'app.parameter_name')]` in the constructor.
* **Prohibition of Hybrid Constructor and `#[Required]`**:
  - `NoConstructorAndRequiredTogetherRule`: Combining `__construct()` and setter methods decorated with `#[Required]` in the same class is prohibited. Use constructor injection exclusively.
  - `NoRequiredOutsideClassRule`: Using `#[Required]` inside PHP traits is strictly forbidden.
* **Modern Tagged Service Iteration**:
  - `NoFindTaggedServiceIdsCallRule`: Calling `findTaggedServiceIds()` manually inside Compiler Passes is prohibited. Use `#[TaggedIterator]` or `#[TaggedLocator]` attributes.

---

## 2. Controllers, Routing, Forms, and Request Mapping

Reference documentation: `controller.rst`, `forms.rst`, `validation.rst`

### 2.1. Thin Single-Action Controllers
* **Rule**: Controllers should be defined as `final` classes containing a single action implemented via the `__invoke()` method.
* **`NoAbstractControllerConstructorRule`**: Abstract base controllers extending `AbstractController` must never define a constructor. Inject dependencies directly into final child controllers.

### 2.2. Declarative Request Mapping (Symfony 7.x & 8.x)
* **Rule**: Replace manual input extraction (`$request->request->all()`, `$request->query->get()`, `$request->getContent()`) with native declarative mapping attributes:
  - `#[MapRequestPayload]`: Deserializes and validates JSON/form request bodies into typed Data Transfer Objects (DTOs).
  - `#[MapQueryString]`: Maps URL query parameters to a typed filter DTO.
  - `#[MapQueryParameter]`: Maps single scalar query parameters (supports `filter: \FILTER_VALIDATE_INT`).
  - `#[MapUploadedFile]`: Binds uploaded files with validation constraints.
  - `#[MapEntity]`: Automatically resolves Doctrine entities from route parameters.
* **Mandatory Mapping Configuration**:
  - When using `#[MapRequestPayload]` or `#[MapQueryString]`, explicitly configure:
    - `acceptFormat: 'json'`
    - `validationGroups: ['create']` (or specific groups)
    - `validationFailedStatusCode: Response::HTTP_UNPROCESSABLE_ENTITY` (or `Response::HTTP_BAD_REQUEST`).
* **Entity Transformation**: Use `Symfony\Component\ObjectMapper\ObjectMapperInterface` (or dedicated mappers) to convert validated DTOs into Doctrine entities.

### 2.3. Unified Routing & Event Architecture
* **`NoRoutingPrefixRule`**: Do not hide routing prefixes inside XML/YAML configuration files. The complete route path must be explicitly visible in the `#[Route]` attribute on the controller class or action.
* **Route Naming & HTTP Methods**:
  - All route names must follow `snake_case` (e.g., `#[Route('/api/orders/{id}', name: 'api_orders_show', methods: ['GET'])]`).
  - Specifying `methods: ['GET', ...]` is recommended for HTTP verb clarity, but omitting it is valid in Symfony (defaults to all methods). Do not flag missing `methods` as a critical bug.
  - **Separation of Concerns**: Never conflate route method hygiene with controller refactoring (e.g., do not bundle rewriting `index()` to `__invoke()` under a routing method recommendation).
* **`NoListenerWithoutContractRule` & `NoStringInGetSubscribedEventsRule`**:
  - Loose event listeners without strict interfaces are prohibited; all subscribers must implement `Symfony\Component\EventDispatcher\EventSubscriberInterface`.
  - In `getSubscribedEvents()`, string event names are prohibited when a class constant is available. Always use `EventClass::class`.

### 2.4. Symfony Form Architecture
* **Dedicated Form Classes**: Forms must be defined as standalone classes extending `AbstractType`. Constructing forms inline in controllers via `createFormBuilder()` is prohibited.
* **Buttons in Twig**: Submit buttons must be rendered in Twig templates (`<button type="submit">`), not declared in `buildForm()` via `SubmitType`.
* **Validation on Target Objects**: Validation constraints must reside on the underlying DTO or Entity, not in FormType options.
* **Translation Key Standards**: Translation keys must describe the *purpose* of the field (`label.username`), never its physical visual location (`user_form.top_row.label.username`).

---

## 3. Doctrine ORM & Database Performance ($N+1$ Elimination)

Reference documentation: `doctrine.rst`, `entity.rst`

### 3.1. Entity Mapping & Repository Purity
* **Native PHP Attributes**: All entity mappings must use native attributes (`#[ORM\Entity]`, `#[ORM\Column]`, `#[ORM\ManyToOne]`, etc.). XML, YAML, and legacy annotations (`@ORM\...`) are prohibited.
* **`ServiceEntityRepository` Inheritance**: Every custom repository must extend `Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository` and invoke `parent::__construct($registry, TargetEntity::class)`.
* **Repository Injection Recommendation**:
  - Prefer injecting the dedicated repository service (e.g., `FaqItemRepository $faqRepository`) directly via constructor property promotion instead of calling `$entityManager->getRepository(Entity::class)`. Direct injection provides static type safety and explicit service contracts.
  - **Pragmatic Note**: Calling `$entityManager->getRepository(Entity::class)` is standard, supported Doctrine syntax (featured throughout Symfony and Doctrine official documentation). It must be categorized as an optional `MINOR` architectural recommendation, NEVER as a `CRITICAL` anti-pattern or prohibited service locator.

### 3.2. Absolute Elimination of $N+1$ Queries & Memory Leaks
* **Prohibition of `findAll()` with In-Memory PHP Filtering**: Calling `findAll()` and subsequently filtering records with `foreach`, `array_filter`, or if-conditions in PHP is a critical defect. All filtering, pagination, and sorting must occur in the database via `QueryBuilder` or `DQL`.
* **In-Memory Filtering vs `setMaxResults()`**:
  - Prefer SQL-level limiting (`->setMaxResults($limit)`) over hydrating entire result sets and calling PHP `array_slice()`.
  - **Pagination Caution**: If the query joins to-many associations (`fetchJoinCollection`), standard SQL `setMaxResults()` truncates related collection rows; use `Doctrine\ORM\Tools\Pagination\Paginator` instead. Always ensure an explicit `orderBy` clause is present so that the limited result set is deterministic.
* **`EntityManager::flush()` in Loops**:
  - Avoid calling `flush()` inside iterative loops.
  - **Caution on State Dependencies**: When moving `flush()` outside a loop, verify whether subsequent loop iterations perform `findOneBy` looking for entities created in previous iterations (since uncommitted entities are not seen by Doctrine queries unless flushed).
* **Fetch Modes (`LAZY` vs `EXTRA_LAZY`)**:
  - Relationships must default to `fetch: 'LAZY'`.
  - For large collections where code calls `count()`, `contains()`, or `slice()`, use `fetch: 'EXTRA_LAZY'`.
* **Mandatory Join Fetching in Lists**: When fetching collections whose related entities will be rendered in a template, serialized to JSON, or processed in bulk, the repository method must explicitly join and select associations via `->innerJoin('o.relation', 'r')->addSelect('r')` (or `leftJoin`).
* **`EntityType` QueryBuilder Consistency**: In Symfony Form `EntityType` fields, custom `query_builder` callbacks must always return the root entity declared in `class` (matching the `FROM` alias). Returning a joined entity breaks form validation and data binding.

---

## 4. Symfony Core Coding Standards & OWASP Security

Reference documentation: `contributing/code/standards.rst`, OWASP Symfony Guidelines

### 4.1. Strict Typing and File Structure
* **File Header**: In greenfield source files and shared packages, add `declare(strict_types=1);` followed by an empty line. Files must end with a single LF newline.
  - **Pragmatic Scope**: While strongly recommended for type safety, Symfony does not mandate `declare(strict_types=1);` for applications (default Symfony skeleton recipes and `Kernel.php` omit it). Treat missing strict types as an informational/minor recommendation, not a critical architectural defect.
* **Line Length Limit**: Lines should ideally not exceed 120 characters.
* **Parameter & Return Types**: All methods and functions must specify full argument and return types. Use `return null;` when explicitly returning `null`, and `return;` in `void` functions. (In PHPUnit test methods, do not append `: void`).
* **Trailing Commas**: Mandatory trailing commas in multi-line arrays and multi-line constructor property promotion parameter lists.
* **Blank Line Before Return**: Always include an empty line before a `return` statement, unless `return` is the only statement inside a conditional block.

### 4.2. Control Structures & Yoda Conditions
* **Yoda Conditions Scope & Definition**:
  - `contributing/code/standards.rst` is the official standard for *contributors to the Symfony framework core* (`symfony/symfony`), not an enforceable mandate for end-user applications.
  - **Exclusivity to Equality Checks**: When adhering to Yoda style, it applies **EXCLUSIVELY to equality operators**: `==`, `!=`, `===`, and `!==` (e.g., `null === $user`, `'active' === $status`).
  - **Absolute Ban on Inequality Transformations**: Never transform comparison operators (`<`, `>`, `<=`, `>=`). Transforming `$existing > 0` into `0 < $existing` is strictly incorrect and damages readability.
  - In user applications, treat Yoda styling as an optional convention or delegate to PHP-CS-Fixer (`yoda_style`), rather than flagging as defects.
* **No `else` After `return` or `throw`**: Never use `else`, `elseif`, or `break` after a block that terminates with `return` or `throw`.
* **Explicit Braces**: Control structures must always use braces `{}` regardless of body line count. Class instantiations must always use parentheses: `new DateTimeImmutable()`.

### 4.3. Class Member Ordering & Naming Conventions
* **Member Ordering**:
  1. Properties (constants first, then static, then instance properties).
  2. Constructor (`__construct`) as the very first method (in tests, `setUp()` and `tearDown()` immediately follow).
  3. `public` methods, then `protected`, then `private`.
* **Naming Conventions**:
  - `camelCase`: Variables, method names, function names, action arguments.
  - `snake_case`: Configuration parameters (`app.items_per_page`), route names (`api_order_show`), Twig template variables.
  - `SCREAMING_SNAKE_CASE`: Class constants (`Post::STATUS_DRAFT`).
  - `UpperCamelCase` (PascalCase): Classes, interfaces (`*Interface`), abstract classes (`Abstract*`), exceptions (`*Exception`), enum cases (`OrderStatus::Paid`).

### 4.4. Exception Messages & PHPDoc Standards
* **Exception Formatting**: Must be formatted using `sprintf()`, start with an uppercase letter, end with a period `.`, wrap placeholders in double quotes `"%s"`, and use `get_debug_type($variable)` instead of `$variable::class`.
* **PHPDoc Hygiene**: No redundant PHPDoc repeating native types. Mandatory array shapes (`list<Order>`, `array<string, mixed>`) and `@throws`. `null` always placed at the end of union types (`@return string|int|null`).

### 4.5. OWASP Security Standards
* **`NoErrorSilencingRule` & Socket Stream Polling Exception**:
  - The PHP error control operator `@` is generally prohibited for masking application logic errors.
  - **Exception for Low-Level Network/Socket Stream Polling**:
    In low-level socket functions such as `stream_socket_accept($server, $timeout)` and `stream_socket_server()`, timeouts or non-blocking polling emit an unavoidable PHP `E_WARNING` while returning `false`.
    In Symfony debug mode, `ErrorHandler` converts all PHP warnings into `ErrorException`. Stripping `@` from `stream_socket_accept` in polling loops will crash the command on the first timeout tick!
    Therefore, `@stream_socket_accept()` accompanied by an explicit `false === $connection` return check is valid and safe. Alternatively, a scoped `set_error_handler` may be used. Never flag this as a critical vulnerability.
* **Twig Auto-Escaping & `|raw`**:
  - Using the Twig `|raw` filter on untrusted user inputs or un-sanitized RichText from the database is an XSS vulnerability.
  - **False Positive Elimination**: Do NOT flag `|raw` when outputting an internal Twig `{% set var %}...{% endset %}` buffer whose dynamic variables are already escaped inside the loop, or when outputting schema markup from `json_encode` within `<script type="application/ld+json">`.
* **Open Redirect Prevention**: Never pass unvalidated user inputs from the `Request` directly into `$this->redirect()`.
* **Authorization Security**: Enforce `#[IsGranted]` attributes or dedicated `Voter` classes (`VoterInterface`).

---

## 5. [HERMES EVOLVED PATTERNS]
*This section is dynamically updated by the Hermes Self-Evolution Engine (`Subagent-Epsilon`) upon discovering new edge cases, resolved debates, or human corrections.*

### Pattern #HE-001: Messenger Worker Memory Leaks in Long-Running Handlers
* **Discovery Context**: Discovered in long-running `messenger:consume` workers where entities were held in identity map.
* **Bad Code**:
```php
public function __invoke(ProcessOrderMessage $msg): void {
    $order = $this->orderRepo->find($msg->orderId);
    // Entity remains attached in EntityManager; memory grows unbounded across messages
}
```
* **Good Code**:
```php
public function __invoke(ProcessOrderMessage $msg): void {
    $order = $this->orderRepo->find($msg->orderId);
    $this->process($order);
    $this->entityManager->clear(); // Detach entities to prevent worker memory leaks
}
```
* **Grounding**: `messenger.rst` (Section: "Avoiding Memory Leaks in Long-Running Workers")

### Pattern #HE-002: In-Memory Query Result Slicing vs Database-Level Pagination
* **Discovery Context**: Discovered during audit of repository list queries (e.g. `FaqItemRepository::findForHome`) where `publishedQuery()->getQuery()->getResult()` was called, followed by `array_slice($items, 0, 5)` in PHP.
* **Bad Code**:
```php
public function findForHome(): array {
    $items = $this->publishedQuery()
        ->andWhere('faq.showOnHome = true')
        ->getQuery()
        ->getResult();

    return array_slice($items, 0, 5); // Entire table hydrated into memory
}
```
* **Good Code**:
```php
public function findForHome(int $limit = 5): array {
    return $this->publishedQuery()
        ->andWhere('faq.showOnHome = true')
        ->setMaxResults($limit) // SQL LIMIT executed at database level
        ->getQuery()
        ->getResult();
}
```
* **Grounding**: `doctrine.rst` (Section: "Limiting and Pagination")

### Pattern #HE-003: Iterative EntityManager Flush in Data Seeding & Batch Loops
* **Discovery Context**: Discovered in command seeders (e.g. `SeedWorkCommand`) where `$this->entityManager->flush()` was executed inside a `foreach` loop for every entity.
* **Bad Code**:
```php
foreach ($items as $row) {
    $entity = new Entity();
    $entity->populate($row);
    $this->entityManager->persist($entity);
    $this->entityManager->flush(); // Triggers N synchronous round-trips & repeated UoW recalculations
}
```
* **Good Code**:
```php
foreach ($items as $row) {
    $entity = new Entity();
    $entity->populate($row);
    $this->entityManager->persist($entity);
}
$this->entityManager->flush(); // Single consolidated transaction
```
* **Grounding**: `doctrine.rst` (Section: "Batch Processing")

### Pattern #HE-004: Socket Stream Polling and Error Silencing Exception
* **Discovery Context**: Identified during human review of `ConnectGoogleReviewsCommand`. Stripping `@` from `stream_socket_accept($server, 1)` caused fatal `ErrorException` in Symfony debug mode due to `ErrorHandler` capturing standard timeout `E_WARNING`.
* **Rule**: `@stream_socket_accept()` or `@stream_socket_server()` with immediate `false === $result` checking is standard low-level PHP I/O and must not be flagged as an OWASP flaw.

### Pattern #HE-005: Yoda Conditions Scope and Inequality Preservation
* **Discovery Context**: Identified during human review where `$existing > 0` was incorrectly rewritten as `0 < $existing`.
* **Rule**: Yoda conditions apply strictly to `==`, `!=`, `===`, `!==`. Never transform `<` or `>`. In userland applications, Yoda style is an optional preference.

### Pattern #HE-006: Twig Buffered Blocks (`{% set %}`) and Safe `|raw` Usage
* **Discovery Context**: Identified in `_faq_list.html.twig` where `{{ faq_items|raw }}` was flagged as XSS despite dynamic variables inside the `{% set %}` block already being auto-escaped by Twig.
* **Rule**: Verify variable origin before reporting XSS on `|raw`. If the variable is an internal Twig capture block of already escaped variables, `|raw` is safe and required to avoid double-escaping HTML tags.

### Pattern #HE-007: Doctrine `getRepository()` vs Constructor Injection
* **Discovery Context**: Identified where `$entityManager->getRepository(...)` was mislabeled as a "CRITICAL Service Locator Anti-Pattern".
* **Rule**: `$entityManager->getRepository()` is valid, fully supported Doctrine syntax. Constructor injection of custom repositories is a clean-code recommendation (`MINOR`), never a critical defect.
