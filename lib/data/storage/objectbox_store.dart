import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/news_storage.dart';

class ObjectBoxStore implements NewsStorage {
  final Store store;
  final Box<NewsItem> newsBox;
  final Box<Category> categoryBox;

  ObjectBoxStore.fromStore(this.store)
    : newsBox = Box<NewsItem>(store),
      categoryBox = Box<Category>(store) {
    _seedIfEmpty();
  }

  static Future<ObjectBoxStore> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(docsDir.path, "news_db"));
    return ObjectBoxStore.fromStore(store);
  }

  @override
  Future<void> insertMany(List<NewsItem> items) async {
    newsBox.putMany(items);
  }

  @override
  List<NewsItem> getAll() {
    return newsBox.getAll();
  }

  @override
  Set<String> getAllRemoteIds() {
    final query = newsBox.query().build();
    final ids = query.property(NewsItem_.remoteId).find().toSet();
    query.close();
    return ids;
  }

  @override
  Stream<List<NewsItem>> watchAllItems() {
    return newsBox
        .query()
        .order(NewsItem_.publishDate, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((q) => q.find());
  }

  @override
  Future<List<Category>> getAllCategories() async {
    return categoryBox.getAll();
  }

  @override
  Future<void> seedCategories(List<Category> categories) async {
    categoryBox.putMany(categories);
  }

  @override
  Stream<List<NewsItem>> watchItemsByCategory(int categoryId) {
    return newsBox
        .query(NewsItem_.category.equals(categoryId))
        .order(NewsItem_.publishDate, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((q) => q.find());
  }

  @override
  Future<void> clearAllNews() async {
    newsBox.removeAll();
  }

  @override
  Future<void> updateNewsStatus(
    int id, {
    bool? isRead,
    bool? isBookmarked,
  }) async {
    final item = newsBox.get(id);
    if (item != null) {
      if (isRead != null) item.isRead = isRead;
      if (isBookmarked != null) item.isBookmarked = isBookmarked;
      newsBox.put(item);
    }
  }

  @override
  Stream<List<NewsItem>> watchBookmarks() {
    return newsBox
        .query(NewsItem_.isBookmarked.equals(true))
        .order(NewsItem_.publishDate, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((q) => q.find());
  }

  void _seedIfEmpty() {
    if (categoryBox.isEmpty()) {
      final defaults = [
        Category(
          name: 'ISNA',
          remoteUrl: 'https://www.isna.ir/rss',
          source: 'ISNA',
        ),
        Category(
          name: 'Mehr',
          remoteUrl: 'https://www.mehrnews.com/rss',
          source: 'Mehr',
        ),
        Category(
          name: 'IRNA',
          remoteUrl: 'https://www.irna.ir/rss',
          source: 'IRNA',
        ),
        Category(
          name: 'Tasnim',
          remoteUrl: 'https://www.tasnimnews.com/fa/rss/feed/0/7/1/',
          source: 'Tasnim',
        ),
      ];
      categoryBox.putMany(defaults);
    }
  }

  @override
  Future<void> close() async => store.close();
}
