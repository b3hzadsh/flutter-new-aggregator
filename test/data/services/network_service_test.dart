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
}
