# Design Doc: App Theme (RTL + Material 3)

## Goal
Implement a consistent Material 3 theme for the Iranian News Aggregator with full RTL support and custom typography using the Vazirmatn font.

## Components

### 1. Dependencies
Add `flutter_localizations` to `pubspec.yaml` to support RTL and localized Material widgets.

### 2. Typography
Use the `Vazirmatn` font family.
- `bodyLarge`: Line height 1.6 for improved readability in Farsi.
- `bodyMedium`: Line height 1.6.
- `titleLarge`: Bold weight for headlines.

### 3. Theme Configuration (`AppTheme`)
- `useMaterial3: true`
- `colorScheme`: Generated from a teal seed color.
- `fontFamily`: 'Vazirmatn'

### 4. Global RTL Setup (`main.dart`)
- `localizationsDelegates`:
  - `GlobalMaterialLocalizations.delegate`
  - `GlobalWidgetsLocalizations.delegate`
  - `GlobalCupertinoLocalizations.delegate`
- `supportedLocales`: `[Locale('fa', 'IR')]`
- `locale`: `Locale('fa', 'IR')`

## Implementation Steps
1. Update `pubspec.yaml` with `flutter_localizations`.
2. Create `lib/presentation/theme/app_theme.dart`.
3. Update `lib/main.dart` to use the theme and RTL settings.
