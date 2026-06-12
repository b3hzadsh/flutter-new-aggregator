# Implement Network and Connectivity Services Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement `NetworkService` to detect Iranian IP and internet connectivity.

**Architecture:** Use `dio` for IP detection and `connectivity_plus` for internet status. Dependency injection for both.

**Tech Stack:** Flutter, Dio, Connectivity Plus, Mocktail (tests).

---

### Task 1: NetworkService Infrastructure and isIranianIp

**Files:**
- Create: `lib/data/services/network_service.dart`
- Create: `test/data/services/network_service_test.dart`

- [ ] **Step 1: Write the failing test for isIranianIp**

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_aggregator/data/services/network_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MockDio extends Mock implements Dio {}
class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late NetworkService networkService;
  late MockDio mockDio;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockDio = MockDio();
    mockConnectivity = MockConnectivity();
    networkService = NetworkService(mockDio, mockConnectivity);
  });

  group('isIranianIp', () {
    test('returns true when countryCode is IR', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: {'countryCode': 'IR'},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await networkService.isIranianIp();

      expect(result, isTrue);
      verify(() => mockDio.get('http://ip-api.com/json')).called(1);
    });

    test('returns false when countryCode is not IR', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: {'countryCode': 'US'},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await networkService.isIranianIp();

      expect(result, isFalse);
    });

    test('returns false when request fails', () async {
      when(() => mockDio.get(any())).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final result = await networkService.isIranianIp();

      expect(result, isFalse);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/services/network_service_test.dart`
Expected: FAIL (NetworkService not defined)

- [ ] **Step 3: Write minimal implementation for isIranianIp**

```dart
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final Dio dio;
  final Connectivity connectivity;

  NetworkService(this.dio, this.connectivity);

  Future<bool> isIranianIp() async {
    try {
      final response = await dio.get('http://ip-api.com/json');
      return response.data['countryCode'] == 'IR';
    } catch (_) {
      return false;
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/data/services/network_service_test.dart`
Expected: PASS

### Task 2: Implement hasInternet

**Files:**
- Modify: `lib/data/services/network_service.dart`
- Modify: `test/data/services/network_service_test.dart`

- [ ] **Step 1: Write the failing test for hasInternet**

Add to `test/data/services/network_service_test.dart`:
```dart
  group('hasInternet', () {
    test('returns true when connected to wifi', () async {
      when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.wifi]);

      final result = await networkService.hasInternet();

      expect(result, isTrue);
    });

    test('returns false when no connection', () async {
      when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.none]);

      final result = await networkService.hasInternet();

      expect(result, isFalse);
    });
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/services/network_service_test.dart`
Expected: FAIL (hasInternet not defined)

- [ ] **Step 3: Write minimal implementation for hasInternet**

```dart
  Future<bool> hasInternet() async {
    final List<ConnectivityResult> results = await connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/data/services/network_service_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/data/services/network_service.dart test/data/services/network_service_test.dart
git commit -m "feat: implement NetworkService for IP and connectivity checks"
```
