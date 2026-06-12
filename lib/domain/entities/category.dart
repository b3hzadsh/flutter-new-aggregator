import 'package:objectbox/objectbox.dart';
import 'feed_source.dart';

@Entity()
class Category {
  @Id()
  int id = 0;

  @Unique()
  final String slug;

  @Index()
  final String name;

  @Backlink()
  final feeds = ToMany<FeedSource>();

  Category({
    this.id = 0,
    required this.slug,
    required this.name,
  });
}
