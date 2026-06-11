# Design Doc: Iranian News Aggregator

## Overview
A robust, high-performance news aggregator Flutter application optimized for Iranian users. The app follows an offline-first approach using a reactive ObjectBox engine, focusing on minimalist Material 3 aesthetics and superior RTL readability.

## Tech Stack
- **Framework:** Flutter (Latest Stable)
- **State Management:** Bloc/Cubit
- **Local Storage:** ObjectBox (NoSQL)
- **Networking:** Dio
- **Typography:** Vazirmatn (Farsi optimized)
- **UI/UX:** Material 3, Hero Transitions, RTL Support

## Architecture: Reactive ObjectBox Engine
The application utilizes a "Database as Single Source of Truth" pattern.

### Layers
1. **Domain Layer:** 
   - `NewsItem`: ObjectBox Entity defining the schema.
2. **Data Layer:**
   - `RssDataSource`: Fetches and parses RSS feeds using Dio and `xml` package.
   - `SyncService`: Coordinates "Sync-on-open" logic and Local Notifications.
   - `ObjectBoxStore`: Manages the database instance and reactive queries.
3. **Presentation Layer:**
   - `NewsCubit`: Subscribes to ObjectBox streams and emits UI states.
   - **Widgets:** RTL-configured Material 3 components with Vazirmatn typography.

## Sync Engine & Offline-First
- **Trigger:** Initiated on app launch (`SyncService.sync()`).
- **Strategy:** Fetches RSS feeds from:
  - ISNA (`https://www.isna.ir/rss`)
  - Mehr News (`https://www.mehrnews.com/rss`)
  - IRNA (`https://www.irna.ir/rss`)
  - Tasnim News (`https://www.tasnimnews.com/fa/rss/feed/0/7/1/`)
- **Persistence:** Smart "upsert" in ObjectBox matching by unique `remoteId`.
- **Notifications:** Detects new high-priority headlines post-sync and triggers `flutter_local_notifications`.

## ObjectBox Entity: `NewsItem`
| Field | Type | Attributes |
|---|---|---|
| `id` | `int` | Internal ObjectBox ID |
| `remoteId` | `String` | Unique index (URL/Hash) |
| `title` | `String` | Indexed for search |
| `content` | `String` | Full news body |
| `summary` | `String` | List view snippet |
| `imageUrl` | `String?` | Optional thumbnail |
| `sourceName` | `String` | e.g., "ISNA" |
| `publishDate` | `DateTime` | Indexed for sorting |
| `isRead` | `bool` | User state |
| `isPriority` | `bool` | Sync engine flag |

## UI/UX & RTL Implementation
- **Typography:** Global `Vazirmatn` font with custom line heights (1.5x - 1.8x).
- **RTL:** `TextDirection.rtl` enforced globally.
- **Transitions:** `Hero` widgets for image and title between list and detail screens.
- **Design:** Material 3 Card layout, teal/indigo accents on clean gray surfaces.

## Search Strategy
- **Full-Text Search:** Utilizes ObjectBox's native C++ String querying.
- **Scope:** Real-time filtering on `title` and `content`.
