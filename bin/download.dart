import 'dart:io';

import 'package:arbify/arbify_download.dart';
import 'package:args/args.dart';

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

Config config;
OutputFileUtils fileUtils;

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

  config = Config(
    apiUrl: pubspec.url,
    projectId: pubspec.projectId,
    outputDir: pubspec.outputDir ?? 'lib/l10n',
    apiSecret: apiSecret,
  );

  fileUtils = OutputFileUtils(outputDir: config.outputDir);

  if (!fileUtils.dirExists()) {
    stdout.write("\nOutput directory doesn't exist. Creating... ");
    fileUtils.createDir();
    stdout.write('done.\n');
  }

  // Fetching ARB files, if needed.
  await fetchExports();
  saveL10nFile();
}

final arbFilesPattern = RegExp(r'intl_(.*)\.arb');

void fetchExports() async {
  final api = ArbifyApi(apiUrl: config.apiUrl, secret: config.apiSecret);
  final arbParser = ArbParser();

  final localArbFiles = fileUtils.fetch(arbFilesPattern);

  final availableExports = await api.fetchAvailableExports(config.projectId);
  final availableLocalFiles = Map.fromEntries(
    localArbFiles.map((contents) {
      final arb = arbParser.parseString(contents);

      return MapEntry(arb.locale, arb.lastModified);
    }),
  );

  for (var availableExport in availableExports) {
    stdout.write(availableExport.languageCode.padRight(20));

    final localFileLastModified =
        availableLocalFiles[availableExport.languageCode];

    // If there is no local file for a given export or if it's older
    // than the available export, download it.
    if (localFileLastModified == null ||
        localFileLastModified.isBefore(availableExport.lastModified)) {
      stdout.write('Downloading... ');

      final remoteArb = await api.fetchExport(
        config.projectId,
        availableExport.languageCode,
      );

      fileUtils.put('intl_${availableExport.languageCode}.arb', remoteArb);

      stdout.write('done.\n');
    } else {
      stdout.write('Up-to-date\n');
    }
  }
}

const templateOrder = ['en', 'en-US', 'en-GB'];

void saveL10nFile() {
  final localFiles = fileUtils.fetch(arbFilesPattern);

  final arbParser = ArbParser();

  final locales = <String>[];
  ArbFile template;
  for (var file in localFiles) {
    final arb = arbParser.parseString(file);

    locales.add(arb.locale);
    // Use file with highest priority as a template
    // or the first one as a fallback.
    if (template == null ||
        templateOrder.contains(arb.locale) &&
            templateOrder.indexOf(arb.locale) <
                templateOrder.indexOf(template.locale)) {
      template = arb;
    }
  }

  if (template == null) {
    print("Couldn't find intl_en.arb to use :(");
    exit(3);
  }

  final generator = L10nDartGenerator();
  final l10nDartContents = generator.generate(template, locales);

  fileUtils.put('l10n.dart', l10nDartContents);
}
