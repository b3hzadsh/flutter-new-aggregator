import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:news_aggregator/presentation/theme/app_theme.dart';
import 'package:news_aggregator/data/storage/objectbox_store.dart';
import 'package:news_aggregator/data/sources/rss_data_source.dart';
import 'package:news_aggregator/data/services/sync_service.dart';
import 'package:news_aggregator/presentation/cubits/news_cubit.dart';
import 'package:news_aggregator/presentation/cubits/theme_cubit.dart';
import 'package:news_aggregator/presentation/pages/news_list_page.dart';
import 'package:news_aggregator/data/services/network_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('fa_IR', null);

  final db = await ObjectBoxStore.create();
  final dio = Dio();
  final connectivity = Connectivity();
  final networkService = NetworkService(dio, connectivity);
  final rssDataSource = RssDataSource(dio: dio);
  final syncService = SyncService(rssDataSource, db);
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(
    db: db,
    syncService: syncService,
    networkService: networkService,
    prefs: prefs,
  ));
}

class MyApp extends StatelessWidget {
  final ObjectBoxStore db;
  final SyncService syncService;
  final NetworkService networkService;
  final SharedPreferences prefs;

  const MyApp({
    super.key,
    required this.db,
    required this.syncService,
    required this.networkService,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: db),
        RepositoryProvider.value(value: syncService),
        RepositoryProvider.value(value: networkService),
        RepositoryProvider.value(value: prefs),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => NewsCubit(db, syncService, networkService)),
          BlocProvider(create: (context) => ThemeCubit(prefs)),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'خبرخوان ایرانی',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
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
            );
          },
        ),
      ),
    );
  }
}
