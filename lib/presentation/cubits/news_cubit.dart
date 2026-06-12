import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../domain/entities/news_item.dart';
import '../../domain/repositories/news_storage.dart';
import '../../data/services/sync_service.dart';
import '../../data/services/network_service.dart';

class NewsState {
  final List<NewsItem> items;
  final bool isLoading;
  final String? error;
  final String? selectedCategoryId;
  final String? selectedCategoryName;
  final bool isShowingBookmarks;

  NewsState({
    required this.items,
    this.isLoading = false,
    this.error,
    this.selectedCategoryId,
    this.selectedCategoryName,
    this.isShowingBookmarks = false,
  });

  NewsState copyWith({
    List<NewsItem>? items,
    bool? isLoading,
    String? error,
    String? selectedCategoryId,
    String? selectedCategoryName,
    bool clearCategory = false,
    bool? isShowingBookmarks,
  }) {
    return NewsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      selectedCategoryName: clearCategory ? null : (selectedCategoryName ?? this.selectedCategoryName),
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
    } else if (state.selectedCategoryId != null) {
      stream = db.watchItemsByCategory(state.selectedCategoryId!);
    } else {
      stream = db.watchAllItems();
    }

    _subscription = stream.listen((items) {
      emit(state.copyWith(items: items));
    });
  }

  void selectCategory(String? categoryRemoteId, {String? categoryName}) {
    if (categoryRemoteId == null) {
      emit(state.copyWith(clearCategory: true));
    } else {
      emit(state.copyWith(selectedCategoryId: categoryRemoteId, selectedCategoryName: categoryName));
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
