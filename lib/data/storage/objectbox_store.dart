import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/repositories/news_storage.dart';

class ObjectBoxStore implements NewsStorage {
  late final Store store;
  late final Box<NewsItem> newsBox;

  ObjectBoxStore.fromStore(this.store) {
    newsBox = Box<NewsItem>(store);
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
  Future<void> close() async => store.close();
}
