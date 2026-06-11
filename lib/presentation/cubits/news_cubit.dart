import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../domain/entities/news_item.dart';
import '../../domain/repositories/news_storage.dart';
import '../../data/services/sync_service.dart';

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
  final NewsStorage db;
  final SyncService syncService;
  StreamSubscription? _subscription;

  NewsCubit(this.db, this.syncService) : super(NewsState(items: [])) {
    _subscribe();
  }

  void _subscribe() {
    _subscription = db.watchAllItems().listen((items) {
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

  // Note: Search implementation might need to be added to the interface 
  // if strict isolation for search is required. For now, we'll stick to basic sync.
  void search(String keyword) {
    // ... search logic (placeholder)
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
