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
* **Route Naming**: All route names must follow `snake_case` (e.g., `#[Route('/api/orders/{id}', name: 'api_orders_show', methods: ['GET'])]`).
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
* **No Service Locator Repositories**: Calling `$entityManager->getRepository(Entity::class)` in services or controllers is prohibited. Inject the dedicated repository service directly.

### 3.2. Absolute Elimination of $N+1$ Queries & Memory Leaks
* **Prohibition of `findAll()` with In-Memory PHP Filtering**: Calling `findAll()` and subsequently filtering records with `foreach`, `array_filter`, or if-conditions in PHP is a critical defect. All filtering, pagination, and sorting must occur in the database via `QueryBuilder` or `DQL`.
* **Fetch Modes (`LAZY` vs `EXTRA_LAZY`)**:
  - Relationships must default to `fetch: 'LAZY'`.
  - For large collections where code calls `count()`, `contains()`, or `slice()`, use `fetch: 'EXTRA_LAZY'`.
* **Mandatory Join Fetching in Lists**: When fetching collections whose related entities will be rendered in a template, serialized to JSON, or processed in bulk, the repository method must explicitly join and select associations via `->innerJoin('o.relation', 'r')->addSelect('r')` (or `leftJoin`).
* **`EntityType` QueryBuilder Consistency**: In Symfony Form `EntityType` fields, custom `query_builder` callbacks must always return the root entity declared in `class` (matching the `FROM` alias). Returning a joined entity breaks form validation and data binding.

---

## 4. Symfony Core Coding Standards & OWASP Security

Reference documentation: `contributing/code/standards.rst`, OWASP Symfony Guidelines

### 4.1. Strict Typing and File Structure
* **File Header**: Every PHP file must start with `declare(strict_types=1);` followed by an empty line. Files must end with a single LF newline.
* **Line Length Limit**: Lines must not exceed 120 characters.
* **Parameter & Return Types**: All methods and functions must specify full argument and return types. Use `return null;` when explicitly returning `null`, and `return;` in `void` functions. (In PHPUnit test methods, do not append `: void`).
* **Trailing Commas**: Mandatory trailing commas in multi-line arrays and multi-line constructor property promotion parameter lists.
* **Blank Line Before Return**: Always include an empty line before a `return` statement, unless `return` is the only statement inside a conditional block.

### 4.2. Control Structures & Yoda Conditions
* **Mandatory Yoda Conditions**: For operators `==`, `!=`, `===`, and `!==`, Yoda conditions are mandatory when comparing a variable against a literal, constant, or expression (`null === $user`).
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
* **`NoErrorSilencingRule`**: The PHP error control operator `@` is strictly prohibited.
* **Twig Auto-Escaping & `|raw`**: Using the Twig `|raw` filter without pre-sanitization via `HtmlSanitizerInterface` is a critical XSS vulnerability.
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
