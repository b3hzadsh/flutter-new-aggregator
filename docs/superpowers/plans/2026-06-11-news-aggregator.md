# Iranian News Aggregator Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a robust, offline-first news aggregator for Iranian users with Material 3 RTL UI, reactive ObjectBox engine, and Vazirmatn typography.

**Architecture:** Reactive ObjectBox Engine (UI observes DB streams). Sync-on-open fetches RSS feeds via Dio, parses XML, and upserts into ObjectBox.

**Tech Stack:** Flutter, ObjectBox, Cubit, Dio, xml, flutter_local_notifications, Vazirmatn font.

---

## File Map

- **Config:**
  - `pubspec.yaml`: Dependencies and assets.
  - `analysis_options.yaml`: Linting rules.
- **Domain:**
  - `lib/domain/entities/news_item.dart`: ObjectBox entity for news.
- **Data:**
  - `lib/data/storage/objectbox_store.dart`: Database initialization and access.
  - `lib/data/sources/rss_data_source.dart`: RSS fetching and XML parsing.
  - `lib/data/services/sync_service.dart`: Orchestrates sync and notifications.
- **Presentation:**
  - `lib/presentation/theme/app_theme.dart`: Material 3 RTL theme with Vazirmatn.
  - `lib/presentation/cubits/news_cubit.dart`: Manages reactive news state.
  - `lib/presentation/pages/news_list_page.dart`: Main scrollable list.
  - `lib/presentation/pages/news_detail_page.dart`: News details with Hero transitions.
  - `lib/presentation/widgets/news_card.dart`: Individual news item card.

---

## Phase 1: Foundation & Data Layer

### Task 1: Dependencies & Assets
**Files:**
- Modify: `pubspec.yaml`
- Create: `assets/fonts/Vazirmatn-Regular.ttf` (placeholder/download instruction)

- [x] **Step 1: Update pubspec.yaml with dependencies**
- [x] **Step 2: Run `flutter pub get`**
- [x] **Step 3: Create assets folder and add a font file**
- [x] **Step 4: Commit**
```bash
git add pubspec.yaml
git commit -m "chore: add project dependencies and font config"
```

### Task 2: NewsItem Entity
**Files:**
- Create: `lib/domain/entities/news_item.dart`

- [x] **Step 1: Define the ObjectBox Entity**
- [x] **Step 2: Run build_runner to generate ObjectBox code**
- [x] **Step 3: Commit**
```bash
git add lib/domain/entities/news_item.dart
git commit -m "feat: define NewsItem entity and generate ObjectBox code"
```

### Task 3: ObjectBox Store Manager
**Files:**
- Create: `lib/data/storage/objectbox_store.dart`

- [x] **Step 1: Implement ObjectBoxStore class**
- [x] **Step 2: Commit**
```bash
git add lib/data/storage/objectbox_store.dart
git commit -m "feat: implement ObjectBox store manager"
```

### Task 4: RSS Data Source (Fetching & Parsing)
**Files:**
- Create: `lib/data/sources/rss_data_source.dart`
- Create: `test/data/sources/rss_data_source_test.dart`

- [x] **Step 1: Write a test for parsing RSS XML**
- [x] **Step 2: Implement RssDataSource with Dio and XML**
- [x] **Step 3: Run test and verify it passes**
- [x] **Step 4: Commit**
```bash
git add lib/data/sources/rss_data_source.dart test/data/sources/rss_data_source_test.dart
git commit -m "feat: add RSS data source and parser"
```

---

## Phase 2: Logic & State

### Task 5: Sync Service
**Files:**
- Create: `lib/data/services/sync_service.dart`

- [x] **Step 1: Implement SyncService with smart upsert**
- [x] **Step 2: Commit**
```bash
git add lib/data/services/sync_service.dart
git commit -m "feat: implement sync service with upsert logic"
```

### Task 6: News Cubit (Reactive)
**Files:**
- Create: `lib/presentation/cubits/news_cubit.dart`

- [x] **Step 1: Implement NewsCubit with ObjectBox Stream**
- [x] **Step 2: Commit**
```bash
git add lib/presentation/cubits/news_cubit.dart
git commit -m "feat: implement reactive NewsCubit"
```

---

## Phase 3: UI & RTL

### Task 7: App Theme (RTL + Material 3)
**Files:**
- Create: `lib/presentation/theme/app_theme.dart`

- [x] **Step 1: Define Material 3 RTL Theme**
- [x] **Step 2: Update `main.dart` to use the theme and RTL globally**
- [x] **Step 3: Commit**
```bash
git add lib/presentation/theme/app_theme.dart lib/main.dart
git commit -m "ui: setup Material 3 RTL theme and typography"
```

### Task 8: News List Page
**Files:**
- Create: `lib/presentation/pages/news_list_page.dart`
- Create: `lib/presentation/widgets/news_card.dart`

- [x] **Step 1: Implement NewsCard with Hero**
- [x] **Step 2: Implement NewsListPage with ListView.builder**
- [x] **Step 3: Commit**
```bash
git add lib/presentation/pages/news_list_page.dart lib/presentation/widgets/news_card.dart
git commit -m "ui: implement news list page with cards and hero tags"
```

### Task 9: News Detail Page
**Files:**
- Create: `lib/presentation/pages/news_detail_page.dart`

- [x] **Step 1: Implement NewsDetailPage with Hero transition**
- [x] **Step 2: Commit**
```bash
git add lib/presentation/pages/news_detail_page.dart
git commit -m "ui: implement news detail page"
```

### Task 10: Final Polish (Sync on Open & Search)
**Files:**
- Modify: `lib/presentation/pages/news_list_page.dart`
- Modify: `lib/main.dart`

- [x] **Step 1: Trigger sync in `main.dart` or `NewsListPage`**
- [x] **Step 2: Add search bar to `NewsListPage` using ObjectBox query**
- [x] **Step 3: Commit**
```bash
git add lib/main.dart lib/presentation/pages/news_list_page.dart
git commit -m "feat: trigger sync on open and add search functionality"
```
