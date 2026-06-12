# Implement Theme Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add dark mode support and theme persistence using `ThemeCubit` and `shared_preferences`.

**Architecture:** Reactive theme management using `flutter_bloc`. The `ThemeCubit` will manage the `ThemeMode` and persist it to `SharedPreferences`. `AppTheme` will provide both light and dark `ThemeData`. `main.dart` will provide the `ThemeCubit` and wire it to `MaterialApp`.

**Tech Stack:** Flutter, flutter_bloc, shared_preferences, Material 3, mocktail (for testing).

---

### Task 1: Update AppTheme with Dark Theme

**Files:**
- Modify: `lib/presentation/theme/app_theme.dart`

- [ ] **Step 1: Add darkTheme to AppTheme**

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.light,
    ),
    fontFamily: 'Vazirmatn',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(height: 1.6),
      bodyMedium: TextStyle(height: 1.6),
      titleLarge: TextStyle(fontWeight: FontWeight.bold),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.dark,
    ),
    fontFamily: 'Vazirmatn',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(height: 1.6),
      bodyMedium: TextStyle(height: 1.6),
      titleLarge: TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/theme/app_theme.dart
git commit -m "feat: add darkTheme to AppTheme"
```

### Task 2: Create ThemeCubit for State Management

**Files:**
- Create: `lib/presentation/cubits/theme_cubit.dart`

- [ ] **Step 1: Implement ThemeCubit**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences prefs;
  static const String _key = 'theme_mode';

  ThemeCubit(this.prefs) : super(_loadThemeMode(prefs));

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final name = prefs.getString(_key);
    return ThemeMode.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ThemeMode.system,
    );
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(newMode);
    prefs.setString(_key, newMode.name);
  }

  void setThemeMode(ThemeMode mode) {
    emit(mode);
    prefs.setString(_key, mode.name);
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/cubits/theme_cubit.dart
git commit -m "feat: implement ThemeCubit for theme persistence"
```

### Task 3: Test ThemeCubit

**Files:**
- Create: `test/presentation/cubits/theme_cubit_test.dart`
- Modify: `test/mocks.dart`

- [ ] **Step 1: Add MockSharedPreferences to test/mocks.dart**

- [ ] **Step 2: Write tests for ThemeCubit**

- [ ] **Step 3: Run tests**

- [ ] **Step 4: Commit**

### Task 4: Integrate ThemeCubit in main.dart

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Initialize SharedPreferences and provide ThemeCubit**

- [ ] **Step 2: Commit**

### Task 5: Add Theme Toggle to NewsListPage

**Files:**
- Modify: `lib/presentation/pages/news_list_page.dart`

- [ ] **Step 1: Add IconButton to SliverAppBar actions**

- [ ] **Step 2: Commit**
