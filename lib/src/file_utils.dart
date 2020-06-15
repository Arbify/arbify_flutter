import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

class FileUtils {
  final String outputDir;

  const FileUtils({@required this.outputDir});

  void put(String filename, String contents) {
    File(path.join(outputDir, filename)).writeAsStringSync(contents);
  }
}
