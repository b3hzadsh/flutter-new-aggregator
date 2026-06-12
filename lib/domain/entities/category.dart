import 'package:objectbox/objectbox.dart';
import 'feed_source.dart';

@Entity()
class Category {
  @Id()
  int id = 0;

  @Unique()
  final String remoteId;

  @Index()
  final String name;

  @Backlink('category')
  final feeds = ToMany<FeedSource>();

  Category({
    this.id = 0,
    required this.remoteId,
    required this.name,
  });
}
