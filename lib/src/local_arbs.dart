import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'export_info.dart';

class LocalArbs {
  final String exportsDir;

  LocalArbs(this.exportsDir);

  bool exportsDirExists() {
    return _exportsDir().existsSync();
  }

  void ensureExportsDir() {
    _exportsDir().createSync(recursive: true);
  }

  List<ExportInfo> fetchExportInfos() {
    final arbFileRegex = RegExp('intl_(.*)\.arb');

    return _exportsDir()
        .listSync()
        .whereType<File>()
        .where((file) => arbFileRegex.hasMatch(path.basename(file.path)))
        .map((arbFile) {
          try {
            final arb = json.decode(arbFile.readAsStringSync());

            return ExportInfo(
              arb['@@locale'] ??
                  arbFileRegex.firstMatch(path.basename(arbFile.path)).group(1),
              DateTime.tryParse(arb['@@last_modified'] ?? ''),
            );
          } on Exception {
            return null;
          }
        })
        .where((el) => el != null)
        .toList();
  }

  void put(String languageCode, String contents) {
    File(path.join(_exportsDir().path, 'intl_$languageCode.arb'))
        .writeAsStringSync(contents);
  }

  Directory _exportsDir() =>
      Directory(path.join(Directory.current.path, exportsDir));
}
