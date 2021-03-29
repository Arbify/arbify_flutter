import 'package:dio/dio.dart';

import 'export_info.dart';

class ArbifyApi {
  late final Dio _client;

  ArbifyApi({required Uri apiUrl, required String secret, Dio? client}) {
    _client = client ?? Dio();

    final options = _client.options;
    options.baseUrl = '$apiUrl/api/v1';
    options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Bearer $secret',
    };
  }

  /// Fetches available exports with their last modification date from
  /// a project with a given [projectId].
  Future<List<ExportInfo>> fetchAvailableExportsForProj(int projectId) async {
    final response = await _client.get('/projects/$projectId/arb');

    return (response.data as Map<String, dynamic>).entries.map((entry) {
      return ExportInfo(
        languageCode: entry.key,
        lastModified: DateTime.parse(entry.value as String),
      );
    }).toList();
  }

  Future<String> fetchExport({
    required int projectId,
    required String languageCode,
  }) async {
    final path = '/projects/$projectId/arb/$languageCode';
    final response = await _client.get(path);
    return response.data as String;
  }
}
