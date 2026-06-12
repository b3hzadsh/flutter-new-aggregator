import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../domain/entities/news_item.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/news_storage.dart';
import '../../data/services/sync_service.dart';

class NewsState {
  final List<NewsItem> items;
  final bool isLoading;
  final String? error;
  final Category? selectedCategory;

  NewsState({
    required this.items,
    this.isLoading = false,
    this.error,
    this.selectedCategory,
  });

  NewsState copyWith({
    List<NewsItem>? items,
    bool? isLoading,
    String? error,
    Category? selectedCategory,
    bool clearCategory = false,
  }) {
    return NewsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
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
    _subscription?.cancel();
    final stream = state.selectedCategory == null
        ? db.watchAllItems()
        : db.watchItemsByCategory(state.selectedCategory!.id);

    _subscription = stream.listen((items) {
      emit(state.copyWith(items: items));
    });
  }

  void selectCategory(Category? category) {
    if (category == null) {
      emit(state.copyWith(clearCategory: true));
    } else {
      emit(state.copyWith(selectedCategory: category));
    }
    _subscribe();
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
