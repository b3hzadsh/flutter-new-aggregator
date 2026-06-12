import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_aggregator/presentation/cubits/theme_cubit.dart';
import '../../mocks.dart';

void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
  });

  group('ThemeCubit', () {
    test('initial state is system when no preference is saved', () {
      final cubit = ThemeCubit(mockPrefs);
      expect(cubit.state, ThemeMode.system);
    });

    test('initial state is loaded from preferences', () {
      when(() => mockPrefs.getString('theme_mode')).thenReturn(ThemeMode.dark.name);
      final cubit = ThemeCubit(mockPrefs);
      expect(cubit.state, ThemeMode.dark);
    });

    test('toggleTheme switches between light and dark', () {
      when(() => mockPrefs.getString('theme_mode')).thenReturn(ThemeMode.light.name);
      final cubit = ThemeCubit(mockPrefs);
      
      cubit.toggleTheme();
      expect(cubit.state, ThemeMode.dark);
      verify(() => mockPrefs.setString('theme_mode', ThemeMode.dark.name)).called(1);

      cubit.toggleTheme();
      expect(cubit.state, ThemeMode.light);
      verify(() => mockPrefs.setString('theme_mode', ThemeMode.light.name)).called(1);
    });

    test('setThemeMode updates state and persists', () {
      final cubit = ThemeCubit(mockPrefs);
      
      cubit.setThemeMode(ThemeMode.dark);
      expect(cubit.state, ThemeMode.dark);
      verify(() => mockPrefs.setString('theme_mode', ThemeMode.dark.name)).called(1);
    });
  });
}
