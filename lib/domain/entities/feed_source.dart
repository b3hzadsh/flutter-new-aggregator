import 'package:objectbox/objectbox.dart';
import 'category.dart';

@Entity()
class FeedSource {
  @Id()
  int id = 0;

  @Index()
  final String name;

  @Unique()
  final String url;

  final String language;
  final bool isLocalOnly;

  final category = ToOne<Category>();

  FeedSource({
    this.id = 0,
    required this.name,
    required this.url,
    required this.language,
    this.isLocalOnly = false,
  });
}
