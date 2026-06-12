import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../domain/entities/news_item.dart';

class NewsCard extends StatelessWidget {
  final NewsItem item;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;

  const NewsCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = intl.DateFormat.yMMMd('fa').format(item.publishDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: item.isRead ? 0.5 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.imageUrl != null)
                Hero(
                  tag: 'image_${item.remoteId}',
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.broken_image, size: 48),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.sourceName,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              dateStr,
                              style: theme.textTheme.labelSmall,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                item.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                size: 20,
                                color: item.isBookmarked ? theme.colorScheme.primary : null,
                              ),
                              onPressed: onBookmarkToggle,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Hero(
                      tag: 'title_${item.remoteId}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          item.title,
                          style: theme.textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.summary,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
