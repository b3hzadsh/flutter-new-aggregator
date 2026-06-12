# Design Spec: Enhanced News Features

This specification covers a suite of features to improve user experience, personalization, and data management in the news aggregator.

## Features
1. **Dynamic Feed Localization:** Automatically switch between Iranian and Global feeds based on user's current IP address during sync.
2. **Bookmarks:** Allow users to save articles for later reading, accessible via a "Saved News" section.
3. **Read Tracking:** Visually distinguish articles already read by the user.
4. **Data Management:** Provide an option to wipe all local news data (including bookmarks).
5. **Dark Mode:** A toggle to switch between light and dark themes.
6. **Connectivity Awareness:** Alert the user via a popup if synchronization fails due to no internet.

## Data Model Updates

### `NewsItem` Entity
- `bool isBookmarked`: Defaults to `false`.
- `bool isRead`: (Existing) defaults to `false`.

### `Category` Entity
- `bool isLocalOnly`: If `true`, this feed is only fetched if the user is in Iran.

## Logic & Services

### 1. `NetworkService` (New)
- `Future<bool> isIranianIp()`: Calls `http://ip-api.com/json` to check `countryCode == 'IR'`.
- `Future<bool> hasInternet()`: Checks connectivity status using `connectivity_plus`.

### 2. `ThemeService` (New)
- Manages `ThemeMode` (Light/Dark).
- Persists user preference using `shared_preferences`.

### 3. `SyncService` Update
- Before syncing, it calls `NetworkService.isIranianIp()`.
- It filters the list of `Category` entities to fetch. If the IP is not Iranian, it skips categories where `isLocalOnly` is true.

### 4. `NewsCubit` Enhancements
- `toggleBookmark(int newsId)`: Toggles the bookmark state.
- `markAsRead(int newsId)`: Sets `isRead` to `true`.
- `clearDatabase()`: Deletes ALL `NewsItem` objects from ObjectBox.
- `filterBookmarks(bool onlyBookmarks)`: Filters the reactive stream.

## UI Components

### Sidebar/Drawer
- **Saved News Tile:** Switches the main feed to show only bookmarked items.
- **Dark Mode Toggle:** A `SwitchListTile` to toggle the theme.
- **Clear History Button:** A destructive action to wipe the database.

### News Card
- **Opacity:** Wrap the card content in an `Opacity` widget. If `isRead` is true, opacity is set to `0.5`.
- **Bookmark Icon:** An `IconButton` to quickly save/unsave articles.

### Connectivity Popup
- An `AlertDialog` triggered in `NewsListPage` if `SyncService` throws a network-related error.

## Success Criteria
- [ ] IP detection correctly filters "Local Only" feeds.
- [ ] Bookmarked items persist and are viewable in a filtered list.
- [ ] Read items are visually dimmed.
- [ ] Database clearing removes all items and bookmarks.
- [ ] Dark mode persists across app restarts.
- [ ] A dialog appears on sync failure if no internet is available.
