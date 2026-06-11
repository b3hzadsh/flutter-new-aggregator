import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart';
import '../../domain/entities/news_item.dart';

class ObjectBoxStore {
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

  void close() => store.close();
}
