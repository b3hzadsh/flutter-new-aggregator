# Spec: NewsItem Entity Implementation

## Overview
Implement the `NewsItem` entity as a persistent ObjectBox model. This entity will serve as the primary data structure for news articles in the Iranian News Aggregator.

## Requirements
- **Location:** `lib/domain/entities/news_item.dart`
- **Library:** `package:objectbox/objectbox.dart`
- **Persistence:** Must be compatible with ObjectBox code generation.

## Schema Definition
| Field | Type | Attributes | Description |
|---|---|---|---|
| `id` | `int` | `@Id()` | Internal ObjectBox ID. |
| `remoteId` | `String` | `@Index(type: IndexType.hash)` | Unique identifier from the source RSS. |
| `title` | `String` | `@Index()` | Article title, indexed for search. |
| `content` | `String` | | Full body of the article. |
| `summary` | `String` | | Short snippet for list views. |
| `imageUrl` | `String?` | | URL to the thumbnail image. |
| `sourceName` | `String` | | Name of the news source (e.g., ISNA). |
| `publishDate` | `DateTime` | `@Index()` | When the article was published. |
| `isRead` | `bool` | | Whether the user has opened the article. |
| `isPriority` | `bool` | | Flag for high-importance news. |

## Implementation Plan
1. Create the directory `lib/domain/entities/` if it doesn't exist.
2. Create `lib/domain/entities/news_item.dart` with the specified class and annotations.
3. Run `flutter pub run build_runner build` to generate `lib/objectbox.g.dart`.
4. Verify the generated code.

## Success Criteria
- `lib/domain/entities/news_item.dart` exists and matches the spec.
- `lib/objectbox.g.dart` is successfully generated and includes `NewsItem` metadata.
- Code passes `flutter analyze`.
