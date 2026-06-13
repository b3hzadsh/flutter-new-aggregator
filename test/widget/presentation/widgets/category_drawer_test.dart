import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:news_aggregator/core/error/failures.dart';
import 'package:news_aggregator/presentation/widgets/category_drawer.dart';
import 'package:news_aggregator/presentation/cubits/news_cubit.dart';
import 'package:news_aggregator/presentation/cubits/theme_cubit.dart';
import 'package:news_aggregator/domain/repositories/news_storage.dart';
import 'package:news_aggregator/domain/entities/category.dart';

class MockNewsStorage extends Mock implements NewsStorage {}
class MockNewsCubit extends Mock implements NewsCubit {}
class MockThemeCubit extends Mock implements ThemeCubit {}

void main() {
  late MockNewsStorage mockStorage;
  late MockNewsCubit mockCubit;
  late MockThemeCubit mockThemeCubit;

  setUp(() {
    mockStorage = MockNewsStorage();
    mockCubit = MockNewsCubit();
    mockThemeCubit = MockThemeCubit();

    when(() => mockCubit.db).thenReturn(mockStorage);
    when(() => mockCubit.state).thenReturn(NewsState(items: []));
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(NewsState(items: [])));
    when(() => mockCubit.close()).thenAnswer((_) async {});
    when(() => mockCubit.showBookmarksOnly(any())).thenReturn(null);
    when(() => mockCubit.clearDatabase()).thenAnswer((_) async {});

    when(() => mockThemeCubit.state).thenReturn(ThemeMode.light);
    when(() => mockThemeCubit.stream).thenAnswer((_) => Stream.value(ThemeMode.light));
    when(() => mockThemeCubit.close()).thenAnswer((_) async {});
    when(() => mockThemeCubit.toggleTheme()).thenReturn(null);
  });

  testWidgets('CategoryDrawer displays categories and handles selection', (WidgetTester tester) async {
    final categories = [
      Category(id: 1, slug: 'political', name: 'سیاسی'),
      Category(id: 2, slug: 'sports', name: 'ورزشی'),
    ];

    when(() => mockStorage.getAllCategories()).thenAnswer((_) async => Right(categories));

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<NewsCubit>.value(value: mockCubit),
            BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
          ],
          child: const Scaffold(
            drawer: CategoryDrawer(),
          ),
        ),
      ),
    );

    // Open drawer
    final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    // Verify title
    expect(find.text('دسته‌بندی‌ها'), findsOneWidget);
    
    // Verify "All news" option
    expect(find.text('همه اخبار'), findsOneWidget);

    // Verify categories are displayed
    expect(find.text('سیاسی'), findsOneWidget);
    expect(find.text('ورزشی'), findsOneWidget);

    // Test selection
    await tester.tap(find.text('سیاسی'));
    verify(() => mockCubit.showBookmarksOnly(false)).called(1);
    verify(() => mockCubit.selectCategory(categories[0].slug, categoryName: categories[0].name)).called(1);
    
    // Drawer should be closed after selection (due to Navigator.pop)
    await tester.pumpAndSettle();
    expect(find.byType(CategoryDrawer), findsNothing);
  });

  testWidgets('CategoryDrawer displays saved news and clear history', (WidgetTester tester) async {
    when(() => mockStorage.getAllCategories()).thenAnswer((_) async => const Right(<Category>[]));

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<NewsCubit>.value(value: mockCubit),
            BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
          ],
          child: const Scaffold(
            drawer: CategoryDrawer(),
          ),
        ),
      ),
    );

    final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    expect(find.text('اخبار ذخیره شده'), findsOneWidget);
    expect(find.text('حالت شب'), findsOneWidget);
    expect(find.text('پاک کردن تاریخچه'), findsOneWidget);

    // Test Saved News click
    await tester.tap(find.text('اخبار ذخیره شده'));
    verify(() => mockCubit.showBookmarksOnly(true)).called(1);
    await tester.pumpAndSettle();

    // Re-open drawer for next test
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    // Test Clear History click
    await tester.tap(find.text('پاک کردن تاریخچه'));
    await tester.pumpAndSettle();

    // Verify dialog is shown
    expect(find.text('حذف تاریخچه'), findsOneWidget);

    // Tap "Delete" in dialog
    await tester.tap(find.text('حذف'));
    await tester.pumpAndSettle();

    verify(() => mockCubit.clearDatabase()).called(1);
  });

  testWidgets('CategoryDrawer shows loading indicator while fetching categories', (WidgetTester tester) async {
    // Return a future that doesn't complete immediately
    when(() => mockStorage.getAllCategories()).thenAnswer((_) => Future.delayed(const Duration(seconds: 1), () => const Right(<Category>[])));

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<NewsCubit>.value(value: mockCubit),
            BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
          ],
          child: const Scaffold(
            drawer: CategoryDrawer(),
          ),
        ),
      ),
    );

    final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pump(); // Start the animation

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete the future and wait for all animations/timers to finish
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });
}
