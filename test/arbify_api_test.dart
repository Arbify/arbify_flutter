import 'dart:convert';

import 'package:arbify/src/api/arbify_api.dart';
import 'package:arbify/src/api/export_info.dart';
import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'arbify_api_test.mocks.dart';

@GenerateMocks([HttpClientAdapter])
void main() {
  final dio = Dio();
  late MockHttpClientAdapter adapterMock;
  late ArbifyApi api;
  setUp(() {
    adapterMock = MockHttpClientAdapter();
    dio.httpClientAdapter = adapterMock;
    api = ArbifyApi(
      apiUrl: Uri.parse('https://test'),
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

      final exports = await api.fetchAvailableExportsForProj(2);
      final response = ExportInfo(
        languageCode: 'en',
        lastModified: DateTime.utc(2020, 6, 7, 18, 13, 57),
      );

      expect(exports, isList);
      expect(exports, isNotEmpty);
      expect(exports.first, isA<ExportInfo>());
      expect(exports.first.languageCode, equals(response.languageCode));
      expect(exports.first.lastModified, equals(response.lastModified));
    });
  });

  group('fetchExport', () {
    test('returns valid string', () async {
      const data = '{"@@locale": "en"}';
      final mockResponse = ResponseBody.fromString(data, 200);
      when(adapterMock.fetch(any, any, any))
          .thenAnswer((_) async => mockResponse);

      final export = await api.fetchExport(languageCode: 'en', projectId: 2);
      expect(export, equals(data));
    });
  });
}

ResponseBody _makeJsonResponse(dynamic data, int status) {
  return ResponseBody.fromString(jsonEncode(data), status, headers: {
    'content-type': ['application/json']
  });
}
