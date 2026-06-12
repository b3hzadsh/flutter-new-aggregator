# Design Spec: News Categories Hierarchy and Automatic Cleanup

This specification details the transition to a hierarchical category system and the implementation of an automatic data retention policy.

## 1. Feature Overview

### 1.1 Hierarchical Categories
The current "Category" entity (which represents a single feed) will be split into a parent `Category` (e.g., "Sports") and multiple child `FeedSource` entities (e.g., "ESPN", "BBC Sport"). This structure will be seeded directly from `news_category_link.json`.

### 1.2 Automatic News Cleanup
To maintain app performance and storage efficiency, news items older than 30 days will be automatically deleted during every synchronization cycle.
- **Rule:** Delete if `publishDate` < (Now - 30 days).
- **Exception:** Items marked as `isBookmarked == true` must never be automatically deleted.

## 2. Data Model Updates

### 2.1 `Category` Entity (Updated)
Represents a group of feeds.
- `int id`: ObjectBox ID.
- `String remoteId`: Unique identifier from JSON (e.g., "sports").
- `String name`: Display name in Persian (e.g., "ورزشی").
- `Backlink<FeedSource> feeds`: Relationship to child feeds.

### 2.2 `FeedSource` Entity (New)
Represents a specific RSS feed.
- `int id`: ObjectBox ID.
- `String name`: Display name (e.g., "ESPN").
- `String url`: The RSS link.
- `String language`: "fa" or "en".
- `bool isLocalOnly`: Whether the feed is restricted to Iranian IPs.
- `ToOne<Category> category`: Parent category relationship.

### 2.3 `NewsItem` Entity (Updated)
- `ToOne<FeedSource> feedSource`: Replaces the previous `ToOne<Category>` relationship.

## 3. Logic & Services

### 3.1 `ObjectBoxStore` Seeding
- On initialization, `ObjectBoxStore` will read `news_category_link.json`.
- It will perform an upsert for `Category` and `FeedSource` entities to ensure the database matches the JSON configuration.

### 3.2 `NewsStorage` Repository Interface
Add new methods:
- `Future<void> deleteOldNews(DateTime cutoff)`: Removes non-bookmarked news older than the cutoff.
- `Future<List<Category>> getAllCategories()`: Returns all parent categories.
- `Future<void> syncCategoriesFromJson(String jsonPath)`: Logic to parse and store the JSON structure.

### 3.3 `SyncService` Workflow
1. **Cleanup:** Call `db.deleteOldNews(DateTime.now().subtract(Duration(days: 30)))`.
2. **Filter:** Retrieve all `FeedSource` entities, filtering out `isLocalOnly` feeds if the user is not on an Iranian IP.
3. **Fetch & Save:** Iterate through active feeds, fetch RSS, and save `NewsItem`s linked to their respective `FeedSource`.

## 4. UI Adjustments

### 4.1 `NewsCubit`
- Update `watchItemsByCategory(String categoryRemoteId)`: Query `NewsItem`s where their `feedSource` belongs to the `Category` with the given `remoteId`.

### 4.2 `CategoryDrawer`
- The drawer will now display the list of parent `Category` names. Selecting one will filter the main feed by that category.

## 5. Success Criteria
- [ ] Database contains the hierarchical structure defined in `news_category_link.json`.
- [ ] News items older than 30 days are removed during sync.
- [ ] Bookmarked items remain in the database even if they are older than 30 days.
- [ ] Selecting "Sports" in the UI shows news from all sport-related feeds (ESPN, Varzesh3, etc.).
- [ ] No regression in "Local Only" feed filtering logic.
