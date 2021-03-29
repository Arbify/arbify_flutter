import 'package:universal_io/io.dart';

abstract class PrintInstructions {
  static void pubspec() {
    print("""
You don't have all the required configuration options. You can
copy the template below and place it at the end of your pubspec.

arbify:
  url: https://arb.example.org
  project_id: 12
  output_dir: lib/l10n # This is the default value.""");
  }

  static void apiForbidden(int projectId) {
    print('''
API returned response with a 403 Forbidden status. Make sure you
have access to the project with a project id $projectId and that
you correctly setup the secret. Check .secret.arbify file again.''');
  }

  static void apiNotFound(int projectId) {
    print('''
API returned response with a 404 Not Found status. Make sure you
put right project id in the pubspec.yaml file. The current
project id is $projectId.''');
  }

  static void noInteractiveSecret(Uri arbifyUrl) {
    final createSecretUrl = arbifyUrl.replace(path: '/account/secrets/create');
    print("""
We couldn't find an Arbify secret. Please create a secret using
the URL below, paste it to .secret.arbify file in your project
directory and try again. Don't commit this file to your
version control software.

$createSecretUrl
""");
  }

  static String promptInteractiveSecret(Uri arbifyUrl) {
    final createSecretUrl = arbifyUrl.replace(path: '/account/secrets/create');
    stdout.write("""
We couldn't find an Arbify secret. Please create a secret using
the URL below, paste it here and press Enter.

$createSecretUrl

Secret: """);
    return stdin.readLineSync()!;
  }
}
