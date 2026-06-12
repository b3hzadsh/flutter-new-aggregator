import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_aggregator/presentation/widgets/category_drawer.dart';
import 'package:news_aggregator/presentation/cubits/news_cubit.dart';
import 'package:news_aggregator/domain/repositories/news_storage.dart';
import 'package:news_aggregator/domain/entities/category.dart';
import 'package:news_aggregator/data/services/sync_service.dart';

class MockNewsStorage extends Mock implements NewsStorage {}
class MockSyncService extends Mock implements SyncService {}
class MockNewsCubit extends Mock implements NewsCubit {}

void main() {
  late MockNewsStorage mockStorage;
  late MockSyncService mockSyncService;
  late MockNewsCubit mockCubit;

  setUp(() {
    mockStorage = MockNewsStorage();
    mockSyncService = MockSyncService();
    mockCubit = MockNewsCubit();

    when(() => mockCubit.db).thenReturn(mockStorage);
    when(() => mockCubit.state).thenReturn(NewsState(items: []));
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(NewsState(items: [])));
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  testWidgets('CategoryDrawer displays categories and handles selection', (WidgetTester tester) async {
    final categories = [
      Category(id: 1, name: 'سیاسی', remoteUrl: '', source: ''),
      Category(id: 2, name: 'ورزشی', remoteUrl: '', source: ''),
    ];

    when(() => mockStorage.getAllCategories()).thenAnswer((_) async => categories);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<NewsCubit>.value(
          value: mockCubit,
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
    verify(() => mockCubit.selectCategory(categories[0])).called(1);
    
    // Drawer should be closed after selection (due to Navigator.pop)
    await tester.pumpAndSettle();
    expect(find.byType(CategoryDrawer), findsNothing);
  });

  testWidgets('CategoryDrawer shows loading indicator while fetching categories', (WidgetTester tester) async {
    // Return a future that doesn't complete immediately
    when(() => mockStorage.getAllCategories()).thenAnswer((_) => Future.delayed(const Duration(seconds: 1), () => <Category>[]));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<NewsCubit>.value(
          value: mockCubit,
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
