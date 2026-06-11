# Runtime Debug Protocol

If the app passes automated tests but fails on a real device, follow this 8-step protocol to locate the source of silence.

## 1. Diagnostic Log Checkpoints
Insert these `debugPrint` statements at layer boundaries to trace data flow:

```dart
// 1. Network Exit (in RssDataSource.fetchFeed)
debugPrint('HTTP ${response.statusCode}: Fetched ${response.data.toString().length} bytes');

// 2. Parser Exit (in RssDataSource.parse)
debugPrint('Parsed ${items.length} items. First item title: ${items.firstOrNull?.title}');

// 3. Storage Entrance (in SyncService.sync)
debugPrint('Found ${existingRemoteIds.length} existing IDs. Inserting ${newItems.length} new items.');

// 4. State Emission (in NewsCubit)
debugPrint('Cubit emitting state: ${items.length} items. Error: $error');
```

## 2. Decision Tree

1.  **Does HTTP log show `status 200` but `0 bytes` or HTML body?**
    *   *Cause:* Network blocking (Cloudflare), invalid User-Agent, or Captcha redirect.
    *   *Fix:* Add a custom `User-Agent` header in Dio.
2.  **Does HTTP fail completely (Timeout/Connection Refused)?**
    *   *Cause:* Missing `<uses-permission android:name="android.permission.INTERNET" />` in `AndroidManifest.xml`.
3.  **Are feeds using HTTP instead of HTTPS?**
    *   *Cause:* Android 9+ blocks cleartext traffic.
    *   *Fix:* Add `android:usesCleartextTraffic="true"` to `AndroidManifest.xml` `<application>` tag.
4.  **Does Parser log show `0 items` despite valid byte length?**
    *   *Cause:* XML schema mismatch (e.g., Atom instead of RSS 2.0), or strict XML parser crashing on unescaped HTML characters.
    *   *Fix:* Catch parsing exceptions locally and log `e.toString()`.
5.  **Does Storage log show `Inserting 0 new items` repeatedly?**
    *   *Cause:* The deduplication logic is comparing URLs incorrectly (e.g., HTTP vs HTTPS, or trailing slashes).
6.  **Does Storage log show insertion success, but Cubit log shows `0 items`?**
    *   *Cause:* ObjectBox stream `.watch(triggerImmediately: true)` is failing to trigger, or the `NewsItem_.publishDate` sort is throwing an error due to invalid date formats stored in DB.
7.  **Does Cubit emit items, but UI is blank?**
    *   *Cause:* Theme constraints (e.g., white text on white background), or `ListView.builder` inside an unconstrained parent (missing `Expanded` or `SliverFillRemaining`).
8.  **Does hot-restart work but cold launch fail?**
    *   *Cause:* Race condition in `main.dart`. `SyncService` is fetching before `ObjectBoxStore` is fully initialized, or UI is building before the Cubit has subscribed to the DB stream.
