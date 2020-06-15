import 'dart:io';

import 'package:args/args.dart';
import '../lib/src/arb_parser/arb_parser.dart';
import '../lib/src/local_arbs.dart';
import '../lib/src/api/arbify_api.dart';
import '../lib/src/config.dart';
import '../lib/src/secret.dart';
import '../lib/src/pubspec_config.dart';

const _pubspecConfigurationError = """

You don't have all the required configuration options. You can
copy the template below and place it at the end of your pubspec.

arbify:
  url: https://arb.example.org
  project_id: 12
  # This is the default value.
  # output_dir: lib/l10n
""";

final argParser = ArgParser()
  ..addFlag(
    'help',
    abbr: 'h',
    negatable: false,
    help: 'Shows this help message.',
  )
  ..addFlag(
    'interactive',
    abbr: 'i',
    defaultsTo: true,
    help: 'Whether the command-line utility can ask you interactively.',
  )
  ..addOption(
    'secret',
    abbr: 's',
    valueHelp: 'secret',
    help: 'Secret to be used for authenticating to the Arbify API.\n'
        'Overrides the secret from the .secret.arbify file.',
  );

void main(List<String> args) async {
  final results = argParser.parse(args);
  final interactive = results['interactive'] as bool;
  final argSecret = results['secret'] as String;
  if (results['help']) {
    print('Arbify download command-line utility.');
    print(argParser.usage);
    exit(0);
  }

  final pubspec = PubspecConfig.fromPubspec();
  if (pubspec.url == null || pubspec.projectId == null) {
    print(_pubspecConfigurationError);
    exit(1);
  }

  final secret = Secret();
  String apiSecret;
  if (argSecret != null) {
    apiSecret = argSecret;
  } else if (!secret.exists()) {
    final createSecretUrl =
        pubspec.url.replace(path: '/account/secrets/create');
    if (!interactive) {
      print("""

We couldn't find an Arbify secret. Please create a secret using
the URL below, paste it to .secret.arbify file in your project
directory and try again. Don't commit this file to your
version control software.

$createSecretUrl
""");
      exit(2);
    }

    stdout.write("""

We couldn't find an Arbify secret. Please create a secret using
the URL below, paste it here and press Enter.

$createSecretUrl

Secret: """);
    apiSecret = stdin.readLineSync();
    secret.create(apiSecret);
    secret.ensureGitIgnored();
  } else {
    apiSecret = secret.value();
  }

  final config = Config(
    apiUrl: pubspec.url,
    projectId: pubspec.projectId,
    outputDir: pubspec.outputDir ?? 'lib/l10n',
    apiSecret: apiSecret,
  );

  final api = ArbifyApi(apiUrl: config.apiUrl, secret: config.apiSecret);
  final localArbs = LocalArbs(config.outputDir);

  if (!localArbs.exportsDirExists()) {
    stdout.write("\nOutput directory doesn't exist. Creating... ");
    localArbs.ensureExportsDir();
    stdout.write('done.\n');
  }

  // Fetching ARB files, if needed.

  final arbParser = ArbParser();

  final remoteExports = await api.fetchAvailableExports(config.projectId);
  final localExports = Map.fromEntries(
    localArbs.fetchExports().map((arbContents) {
      final arbFile = arbParser.parseString(arbContents);

      return MapEntry(arbFile.locale, arbFile.lastModified);
    }),
  );

  for (var remoteExport in remoteExports) {
    stdout.write(remoteExport.languageCode.padRight(20));

    final localExport = localExports[remoteExport.languageCode];
    if (localExport == null ||
        localExport.isBefore(remoteExport.lastModified)) {
      stdout.write('Downloading... ');

      final remoteArb = await api.fetchExport(
        config.projectId,
        remoteExport.languageCode,
      );
      localArbs.put(remoteExport.languageCode, remoteArb);

      stdout.write('done.\n');
    } else {
      stdout.write('Up-to-date\n');
    }
  }
}
