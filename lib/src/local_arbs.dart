import 'dart:io';

import 'package:path/path.dart' as path;

class LocalArbs {
  final String exportsDir;

  LocalArbs(this.exportsDir);

  bool exportsDirExists() {
    return _exportsDir().existsSync();
  }

  void ensureExportsDir() {
    _exportsDir().createSync(recursive: true);
  }

  List<String> fetchExports() {
    final filenamePattern = RegExp('intl_(.*)\.arb');

    return _exportsDir()
        .listSync()
        .whereType<File>()
        .where((file) => filenamePattern.hasMatch(path.basename(file.path)))
        .map((arbFile) => arbFile.readAsStringSync())
        .toList();
  }

  void put(String languageCode, String contents) {
    File(path.join(_exportsDir().path, 'intl_$languageCode.arb'))
        .writeAsStringSync(contents);
  }

  Directory _exportsDir() =>
      Directory(path.join(Directory.current.path, exportsDir));
}
