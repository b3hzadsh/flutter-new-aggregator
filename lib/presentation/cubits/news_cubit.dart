import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../domain/entities/news_item.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/news_storage.dart';
import '../../data/services/sync_service.dart';
import '../../data/services/network_service.dart';

class NewsState {
  final List<NewsItem> items;
  final bool isLoading;
  final String? error;
  final Category? selectedCategory;
  final bool isShowingBookmarks;

  NewsState({
    required this.items,
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.isShowingBookmarks = false,
  });

  NewsState copyWith({
    List<NewsItem>? items,
    bool? isLoading,
    String? error,
    Category? selectedCategory,
    bool clearCategory = false,
    bool? isShowingBookmarks,
  }) {
    return NewsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      isShowingBookmarks: isShowingBookmarks ?? this.isShowingBookmarks,
    );
  }
}

class NewsCubit extends Cubit<NewsState> {
  final NewsStorage db;
  final SyncService syncService;
  final NetworkService networkService;
  StreamSubscription? _subscription;

  NewsCubit(this.db, this.syncService, this.networkService) : super(NewsState(items: [])) {
    _subscribe();
  }

  void _subscribe() {
    _subscription?.cancel();
    
    final Stream<List<NewsItem>> stream;
    if (state.isShowingBookmarks) {
      stream = db.watchBookmarks();
    } else if (state.selectedCategory != null) {
      stream = db.watchItemsByCategory(state.selectedCategory!.id);
    } else {
      stream = db.watchAllItems();
    }

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

  Future<void> toggleBookmark(NewsItem item) async {
    await db.updateNewsStatus(item.id, isBookmarked: !item.isBookmarked);
  }

  Future<void> markAsRead(NewsItem item) async {
    if (!item.isRead) {
      await db.updateNewsStatus(item.id, isRead: true);
    }
  }

  Future<void> clearDatabase() async {
    await db.clearAllNews();
  }

  void showBookmarksOnly(bool show) {
    emit(state.copyWith(isShowingBookmarks: show));
    _subscribe();
  }

  Future<void> sync() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      
      if (!await networkService.hasInternet()) {
        emit(state.copyWith(isLoading: false, error: 'NO_INTERNET'));
        return;
      }

      final isIranianIp = await networkService.isIranianIp();
      await syncService.sync(isIranianIp);
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
