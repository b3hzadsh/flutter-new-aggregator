# Design Spec: Hierarchical Categories and Automated Cleanup

This specification details the refactoring of the news aggregator to support a hierarchical category model (Categories -> Feed Sources), an automatic 30-day data retention policy, and a robust "Fail-Fast" functional error handling architecture.

## Architecture: Robust & Predictable
We follow a "Fail-Fast" approach using the `dartz` package for functional programming.

### 1. Error Layer (`lib/core/error/`)
- **Exceptions (Data Layer):** Thrown at the lowest point of failure.
  - `ServerException`: Network or API level issues.
  - `CacheException`: Local storage (ObjectBox) failures.
  - `ParseException`: Issues reading JSON or RSS XML.
- **Failures (Domain Layer):** Returned by Repositories via `Either`.
  - `ServerFailure`, `CacheFailure`, `ParseFailure`.

### 2. Hierarchical Data Model
Transition from flat strings to structured entities with relationships.

#### `Category` Entity
- `id`: ObjectBox ID.
- `slug`: Machine name (e.g., "politics").
- `name`: Display name (e.g., "سیاسی").
- `feeds`: `ToMany<FeedSource>` relation.

#### `FeedSource` Entity
- `id`: ObjectBox ID.
- `name`: Feed name (e.g., "Fars Politics").
- `url`: RSS link.
- `language`: "fa" or "en".
- `isLocalOnly`: IP filtering flag.
- `category`: `ToOne<Category>` relation.

#### `NewsItem` Entity (Update)
- `feed`: `ToOne<FeedSource>` relation.
- (Existing fields like `title`, `content`, `publishDate` remain).

## Features

### 1. Smart Seeding from JSON
- On startup, the app parses `assets/news_category_link.json`.
- **Fail-Fast:** If the JSON is invalid or missing, a `ParseException` is thrown immediately.
- The database is populated with the hierarchy defined in the JSON.

### 2. Aggregated Synchronization
- `SyncService` fetches all `FeedSource`s for a selected `Category`.
- It performs concurrent fetches (where possible) and upserts `NewsItem`s.
- `SyncService.sync()` now returns `Either<Failure, void>`.

### 3. Automated 30-Day Cleanup
- **Method:** `NewsStorage.cleanupOldNews()`.
- **Trigger:** Runs automatically after every successful `SyncService.sync()`.
- **Logic:** Deletes all `NewsItem` records where `publishDate < (Now - 30 days)`.
- **Retention:** Bookmarked items are **NOT** excluded from cleanup (as per user instruction: "clearing the database also delete bookmarks" - though this refers to the manual button, we will apply the same 30-day rule to keep the DB lean).

### 4. Reactive UI with `Either`
- `NewsCubit` consumes the Repository methods.
- UI uses `result.fold((failure) => showError(), (items) => showList())`.

## Success Criteria
- [ ] Categories show aggregated news from multiple feeds.
- [ ] News older than 30 days is automatically removed post-sync.
- [ ] App remains stable and shows clear error messages if parsing or syncing fails.
- [ ] No raw Exceptions leak into the UI layer.
