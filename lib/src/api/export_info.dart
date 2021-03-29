class ExportInfo {
  final String languageCode;
  final DateTime lastModified;

  ExportInfo({required this.languageCode, required this.lastModified});

  @override
  String toString() =>
      'ExportInfo { languageCode: $languageCode, lastModified: $lastModified }';
}
