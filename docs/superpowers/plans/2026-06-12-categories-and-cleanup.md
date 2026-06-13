# Hierarchical Categories and Automated Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the app to support hierarchical categories from JSON, implement automatic 30-day news cleanup, and adopt a robust Fail-Fast functional error handling architecture.

**Architecture:** Clean Architecture with functional error handling using `dartz`. Data Layer throws `Exception`s; Repository Layer catches them and returns `Either<Failure, T>`.

**Tech Stack:** Flutter, BLoC (Cubit), ObjectBox, Dartz, Dio.

---

### Task 1: Error Layer and Dependencies Setup

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/core/error/exceptions.dart`
- Create: `lib/core/error/failures.dart`

- [ ] **Step 1: Add dartz dependency**
Add `dartz: ^0.10.1` to `pubspec.yaml` and run `flutter pub get`.

- [ ] **Step 2: Create Exception classes**
Define `ServerException`, `CacheException`, and `ParseException` in `lib/core/error/exceptions.dart`.

- [ ] **Step 3: Create Failure classes**
Define `ServerFailure`, `CacheFailure`, and `ParseFailure` in `lib/core/error/failures.dart`.

- [ ] **Step 4: Commit**
```bash
git add pubspec.yaml lib/core/error/
git commit -m "chore: setup dartz and robust error layer"
```

### Task 2: Refactor Entities and Relationships

**Files:**
- Modify: `lib/domain/entities/category.dart`
- Create: `lib/domain/entities/feed_source.dart`
- Modify: `lib/domain/entities/news_item.dart`

- [ ] **Step 1: Update Category entity**
Change `remoteUrl` and `source` fields to a `ToMany<FeedSource> feeds` relation. Add a `slug` field.

- [ ] **Step 2: Create FeedSource entity**
Define `FeedSource` with `name`, `url`, `language`, `isLocalOnly`, and a `ToOne<Category> category` relation.

- [ ] **Step 3: Update NewsItem entity**
Replace the `ToOne<Category> category` relation with a `ToOne<FeedSource> feed` relation.

- [ ] **Step 4: Run build_runner**
Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: Commit**
```bash
git add lib/domain/entities/
git commit -m "feat: refactor entities to hierarchical category model"
```

### Task 3: JSON Seeding Logic

**Files:**
- Modify: `lib/data/storage/objectbox_store.dart`

- [ ] **Step 1: Implement JSON Parsing**
Add logic to read `assets/news_category_link.json`, parse it, and seed the `Category` and `FeedSource` boxes. Use Fail-Fast logic (throw `ParseException` if data is invalid).

- [ ] **Step 2: Update NewsStorage interface**
Update methods to return `Future<Either<Failure, T>>` where appropriate.

- [ ] **Step 3: Commit**
```bash
git add lib/data/storage/objectbox_store.dart lib/domain/repositories/news_storage.dart
git commit -m "feat: implement JSON-based seeding for categories and feeds"
```

### Task 4: SyncService and 30-Day Cleanup

**Files:**
- Modify: `lib/data/services/sync_service.dart`
- Modify: `lib/data/storage/objectbox_store.dart`

- [ ] **Step 1: Implement cleanupOldNews()**
In `ObjectBoxStore`, implement a method to delete `NewsItem`s older than 30 days.

- [ ] **Step 2: Refactor SyncService.sync()**
Update to iterate through feeds of a category. Trigger `cleanupOldNews()` after a successful sync.

- [ ] **Step 3: Commit**
```bash
git add lib/data/services/sync_service.dart lib/data/storage/objectbox_store.dart
git commit -m "feat: implement aggregated sync and automated 30-day cleanup"
```

### Task 5: Refactor Cubit and UI for Functional Error Handling

**Files:**
- Modify: `lib/presentation/cubits/news_cubit.dart`
- Modify: `lib/presentation/pages/news_list_page.dart`
- Modify: `lib/presentation/widgets/category_drawer.dart`

- [ ] **Step 1: Update NewsCubit**
Refactor to handle `Either` results and emit appropriate error states using `Failure` messages.

- [ ] **Step 2: Update UI Components**
Ensure the Drawer and List Page react correctly to the new hierarchical structure and error states.

- [ ] **Step 3: Commit**
```bash
git add lib/presentation/
git commit -m "feat: refactor UI to use functional error handling and updated models"
```
