# Design Spec: News Categories

Adding category support to the Flutter News Aggregator to allow users to filter news by topic (e.g., Politics, Sports, Technology) via a Sidebar/Drawer navigation.

## Goals
- Support fixed categorization per RSS feed.
- Provide a Sidebar/Drawer for easy category switching.
- Maintain "Database as Single Source of Truth" and reactive UI patterns.

## Data Model

### `Category` Entity
A new ObjectBox entity to represent a news category and its associated feed.

```dart
@Entity()
class Category {
  @Id()
  int id = 0;

  @Index()
  final String name; // Display name (e.g., "سیاست")
  
  @Unique()
  final String remoteUrl; // RSS feed URL
  
  final String source; // Source name (e.g., "ISNA")

  Category({
    this.id = 0,
    required this.name,
    required this.remoteUrl,
    required this.source,
  });
}
```

### `NewsItem` Entity (Update)
Update the existing `NewsItem` to include a relation to `Category`.

```dart
@Entity()
class NewsItem {
  // ... existing fields ...
  
  final category = ToOne<Category>();

  // ... existing constructor ...
}
```

## Logic Changes

### 1. Database Initialization (`ObjectBoxStore`)
To ensure the app has categories to fetch on first run, we will add a seeding mechanism.
- On startup, check if the `Category` box is empty.
- If empty, insert a default list of categories (ISNA Politics, Mehr Sports, etc.).

### 2. Synchronization (`SyncService`)
The `SyncService` will shift from a hardcoded map to a dynamic query-based approach.
- Fetch all `Category` entities from the database.
- For each category, fetch and parse the RSS feed.
- Assign the `category` relation to each new `NewsItem`.

### 3. State Management (`NewsCubit`)
The `NewsCubit` will be enhanced to handle filtered streams.
- Add `Category? _selectedCategory` to the state.
- Update the reactive stream to filter by `categoryId` if a category is selected.
- Provide a `selectCategory(Category? category)` method.

## UI Components

### Sidebar/Drawer
A new Drawer widget in `NewsListPage`.
- Displays a "All News" (همه اخبار) item.
- Lists all available `Category` entities from the database.
- Tapping a category calls `NewsCubit.selectCategory()`.

## Success Criteria
- [ ] Users can open a Drawer and see a list of categories.
- [ ] Selecting a category filters the news list immediately.
- [ ] `SyncService` correctly populates categories and associations.
- [ ] UI remains RTL compliant and follows Persian typography.
