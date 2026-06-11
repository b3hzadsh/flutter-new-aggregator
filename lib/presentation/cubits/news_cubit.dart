import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../domain/entities/news_item.dart';
import '../../data/storage/objectbox_store.dart';
import '../../data/services/sync_service.dart';
import '../../objectbox.g.dart';

class NewsState {
  final List<NewsItem> items;
  final bool isLoading;
  final String? error;

  NewsState({
    required this.items,
    this.isLoading = false,
    this.error,
  });

  NewsState copyWith({
    List<NewsItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return NewsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class NewsCubit extends Cubit<NewsState> {
  final ObjectBoxStore db;
  final SyncService syncService;
  StreamSubscription? _subscription;

  NewsCubit(this.db, this.syncService) : super(NewsState(items: [])) {
    _subscribe();
  }

  void _subscribe() {
    final query = db.newsBox
        .query()
        .order(NewsItem_.publishDate, flags: Order.descending)
        .watch(triggerImmediately: true);

    _subscription = query.listen((q) {
      final items = q.find();
      emit(state.copyWith(items: items));
    });
  }

  Future<void> sync() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      await syncService.sync();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void search(String keyword) {
    _subscription?.cancel();
    
    if (keyword.isEmpty) {
      _subscribe();
      return;
    }

    final query = db.newsBox
        .query(NewsItem_.title.contains(keyword, caseSensitive: false)
            .or(NewsItem_.content.contains(keyword, caseSensitive: false)))
        .order(NewsItem_.publishDate, flags: Order.descending)
        .watch(triggerImmediately: true);

    _subscription = query.listen((q) {
      emit(state.copyWith(items: q.find()));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
