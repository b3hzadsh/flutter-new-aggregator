# Spec: CategoryDrawer and NewsListPage Updates

## Overview
Enhance the app's navigation and settings by updating the `CategoryDrawer` with bookmark filtering, theme toggling, and data management options. Update `NewsListPage` to reflect the active filter in its title.

## Proposed Changes

### 1. `CategoryDrawer` Enhancement
- **Location:** `lib/presentation/widgets/category_drawer.dart`
- **UI Structure:**
    - Header: Keep existing "دسته‌بندی‌ها" header.
    - Category Section:
        - "همه اخبار" (All News) Tile.
        - Dynamic list of categories from DB.
    - Divider.
    - Preferences Section:
        - "اخبار ذخیره شده" (Saved News) Tile:
            - Icon: `Icons.bookmark`.
            - Action: `cubit.showBookmarksOnly(true)`.
            - Selection State: `selected` if `state.isShowingBookmarks` is true.
        - "حالت شب" (Dark Mode) Switch:
            - Icon: `Icons.dark_mode`.
            - Value: From `ThemeCubit`.
            - Action: `themeCubit.toggleTheme()`.
    - Divider.
    - Action Section:
        - "پاک کردن تاریخچه" (Clear History) Button:
            - Icon: `Icons.delete_sweep`.
            - Action: `cubit.clearDatabase()`.
            - Color: Error color scheme for warning.

### 2. `NewsListPage` Title Update
- **Location:** `lib/presentation/pages/news_list_page.dart`
- **Logic:**
    - If `state.isShowingBookmarks` is true, set title to "اخبار ذخیره شده".
    - Else if `state.selectedCategory` is not null, set title to `state.selectedCategory!.name`.
    - Else, set title to "تازه‌ترین اخبار".

## Logic & Interaction Flow
1. User opens Drawer.
2. User selects "Saved News":
    - `NewsCubit.showBookmarksOnly(true)` is called.
    - Drawer closes.
    - `NewsListPage` title updates to "اخبار ذخیره شده".
    - Content filters to bookmarked items.
3. User selects a category or "All News":
    - `NewsCubit.selectCategory(...)` is called.
    - `NewsCubit.showBookmarksOnly(false)` should also be ensured (can be handled inside `selectCategory` or explicitly).
    - Drawer closes.
    - `NewsListPage` title updates accordingly.

## Verification Plan
- **Manual Test:**
    - Toggle "Saved News" and verify title and list content.
    - Toggle Dark Mode and verify theme change.
    - Tap "Clear History" and verify list is empty.
    - Switch back to "All News" and verify title and content.
- **Automated Test:**
    - Update `category_drawer_test.dart` to check for new tiles.
