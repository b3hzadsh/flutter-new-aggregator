import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:news_aggregator/presentation/theme/app_theme.dart';
import 'package:news_aggregator/data/storage/objectbox_store.dart';
import 'package:news_aggregator/data/sources/rss_data_source.dart';
import 'package:news_aggregator/data/services/sync_service.dart';
import 'package:news_aggregator/presentation/cubits/news_cubit.dart';
import 'package:news_aggregator/presentation/pages/news_list_page.dart';
import 'package:dio/dio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('fa_IR', null);

  final db = await ObjectBoxStore.create();
  final dio = Dio();
  final rssDataSource = RssDataSource(dio: dio);
  final syncService = SyncService(rssDataSource, db);

  // Trigger initial sync
  syncService.sync();

  runApp(MyApp(
    db: db,
    syncService: syncService,
  ));
}

class MyApp extends StatelessWidget {
  final ObjectBoxStore db;
  final SyncService syncService;

  const MyApp({
    super.key,
    required this.db,
    required this.syncService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: db),
        RepositoryProvider.value(value: syncService),
      ],
      child: BlocProvider(
        create: (context) => NewsCubit(db, syncService),
        child: MaterialApp(
          title: 'خبرخوان ایرانی',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fa', 'IR'),
          ],
          locale: const Locale('fa', 'IR'),
          home: const NewsListPage(),
        ),
      ),
    );
  }
}
