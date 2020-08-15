import 'package:meta/meta.dart';
import 'package:dio/dio.dart';

import 'export_info.dart';

class ArbifyApi {
  static const _apiPrefix = '/api/v1';

  final Dio _client;

  ArbifyApi({@required Uri apiUrl, @required String secret, Dio client})
      : _client = client ?? Dio() {
    _client.options = _client.options.merge(
      baseUrl: apiUrl.toString() + _apiPrefix,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $secret',
      },
    );
  }

  /// Fetches available exports with their last modification date from
  /// a project with a given [projectId].
  Future<List<ExportInfo>> fetchAvailableExports(int projectId) async {
    return _client.get('/projects/$projectId/arb').then((response) {
      return (response.data as Map<String, dynamic>)
          .entries
          .map((entry) =>
              ExportInfo(entry.key, DateTime.parse(entry.value as String)))
          .toList();
    });
  }

  Future<String> fetchExport(int projectId, String languageCode) async {
    return _client
        .get('/projects/$projectId/arb/$languageCode')
        .then((response) => response.data as String);
  }
}
