import 'dart:convert';

import 'package:arbify/src/api/arbify_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class DioAdapterMock extends Mock implements HttpClientAdapter {}

void main() {
  final dio = Dio();
  DioAdapterMock adapterMock;
  ArbifyApi api;
  setUp(() {
    adapterMock = DioAdapterMock();
    dio.httpClientAdapter = adapterMock;
    api = ArbifyApi(
      apiUrl: Uri.parse('http://test'),
      secret: 'secret',
      client: dio,
    );
  });

  group('fetchAvailableExports', () {
    test('returns valid json', () async {
      final data = {'en': '2020-06-07T18:13:57.000000Z'};
      final mockResponse = _makeJsonResponse(data, 200);
      when(adapterMock.fetch(any, any, any))
          .thenAnswer((_) async => mockResponse);

      final exports = await api.fetchAvailableExports(2);

      expect(exports, equals(data));
    });
  });

  group('fetchExport', () {
    test('returns valid string', () async {
      final data = '{"@@locale": "en"}';
      final mockResponse = ResponseBody.fromString(data, 200);
      when(adapterMock.fetch(any, any, any))
          .thenAnswer((_) async => mockResponse);

      final export = await api.fetchExport(2, 'en');
      expect(export, equals(data));
    });
  });
}

ResponseBody _makeJsonResponse(dynamic data, int status) {
  return ResponseBody.fromString(jsonEncode(data), status, headers: {
    'content-type': ['application/json']
  });
}
