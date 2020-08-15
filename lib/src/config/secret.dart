import 'package:universal_io/io.dart';

class Secret {
  /// Whether the secret file exists.
  bool exists() => _secretFile().existsSync();

  /// Returns the value from the secret file.
  String value() => _secretFile().readAsStringSync().trim();

  /// Creates a secret file with a given [secret].
  void create(String secret) => _secretFile().writeAsStringSync(secret);

  /// Checks whether `.gitignore` contains an entry for the secret file
  /// and if not, adds it.
  void ensureGitIgnored() {
    final gitignore = _gitignoreFile();
    final secretFileRegex = RegExp(r'^\/?\.secret\.arbify$', multiLine: true);
    if (gitignore.existsSync() &&
        secretFileRegex.hasMatch(gitignore.readAsStringSync())) {
      return;
    }

    gitignore.writeAsStringSync('.secret.arbify', mode: FileMode.append);
  }

  File _secretFile() => File('.secret.arbify');

  File _gitignoreFile() => File('.gitignore');
}
