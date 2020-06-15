class ExportInfo {
  final String languageCode;
  final DateTime lastModified;

  ExportInfo(this.languageCode, this.lastModified);

  @override
  String toString() =>
      'ExportInfo { languageCode: $languageCode, lastModified: $lastModified }';
}
