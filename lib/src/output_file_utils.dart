import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

class OutputFileUtils {
  final String outputDir;

  const OutputFileUtils(this.outputDir);

  bool dirExists() => _dir().existsSync();

  void createDir() => _dir().createSync(recursive: true);

  List<String> fetch([Pattern pattern]) {
    var files = _dir().listSync().whereType<File>();

    if (pattern != null) {
      files = files.where(
          (file) => pattern.allMatches(path.basename(file.path)).isNotEmpty);
    }

    return files.map((file) => file.readAsStringSync()).toList();
  }

  List<String> list([Pattern pattern]) {
    var files = _dir().listSync().whereType<File>();

    if (pattern != null) {
      files = files.where(
          (file) => pattern.allMatches(path.basename(file.path)).isNotEmpty);
    }

    return files.map((file) => file.path).toList();
  }

  void put(String filename, String contents) {
    File(path.join(outputDir, filename)).writeAsStringSync(contents);
  }

  Directory _dir() => Directory(outputDir);
}
