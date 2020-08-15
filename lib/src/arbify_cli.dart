import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:arbify/src/api/arbify_api.dart';
import 'package:arbify/src/arb_parser/arb_file.dart';
import 'package:arbify/src/arb_parser/arb_parser.dart';
import 'package:arbify/src/config/config.dart';
import 'package:arbify/src/config/pubspec_config.dart';
import 'package:arbify/src/config/secret.dart';
import 'package:arbify/src/generator/intl_translation.dart';
import 'package:arbify/src/generator/l10n_dart_generator.dart';
import 'package:arbify/src/output_file_utils.dart';
import 'package:args/args.dart';
import 'package:dio/dio.dart';

class ArbifyCli {
  final _argParser = ArgParser()
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

  final _arbFilesPattern = RegExp(r'intl_(.*)\.arb');

  OutputFileUtils _fileUtils;

  Future<void> run(List<String> args) async {
    final results = _argParser.parse(args);

    if (results['help'] as bool) {
      _printHelp();
      exit(0);
    }

    final config = _getConfig(
      secretOverride: results['secret'] as String,
      interactive: results['interactive'] as bool,
    );
    _fileUtils = OutputFileUtils(config.outputDir);
    _ensureDirectories();

    try {
      await runDownload(config);
    } on DioError catch (e) {
      if (e.type == DioErrorType.RESPONSE) {
        if (e.response.statusCode == 403) {
          _printApiForbidden(config.projectId);
        } else if (e.response.statusCode == 404) {
          _printApiNotFound(config.projectId);
        } else {
          print('API exception\n');
          print(e.toString());
        }
      } else {
        print('Exception while communicating with the Arbify '
            'at ${config.apiUrl.toString()}\n');
        print(e.toString());
      }

      exit(3);
    }
  }

  void _printHelp() {
    print('Arbify download command-line utility.\n');
    print(_argParser.usage);
  }

  Config _getConfig({String secretOverride, bool interactive}) {
    final pubspec = _getPubspecConfig();
    final apiSecret = _getApiSecret(
      arbifyUrl: pubspec.url,
      interactive: interactive,
      overrideSecret: secretOverride,
    );

    return Config(
      apiUrl: pubspec.url,
      projectId: pubspec.projectId,
      outputDir: pubspec.outputDir ?? 'lib/l10n',
      apiSecret: apiSecret,
    );
  }

  PubspecConfig _getPubspecConfig() {
    final pubspec = PubspecConfig.fromPubspec();
    if (pubspec.url == null || pubspec.projectId == null) {
      _printPubspecInstructions();
      exit(1);
    }

    return pubspec;
  }

  void _printPubspecInstructions() {
    print("""
You don't have all the required configuration options. You can
copy the template below and place it at the end of your pubspec.

arbify:
  url: https://arb.example.org
  project_id: 12
  output_dir: lib/l10n # This is the default value.""");
  }

  String _getApiSecret({
    Uri arbifyUrl,
    bool interactive,
    String overrideSecret,
  }) {
    final secret = Secret();

    if (overrideSecret != null) {
      return overrideSecret;
    }

    if (secret.exists()) {
      return secret.value();
    }

    if (!interactive) {
      _printNoInteractiveSecretInstructions(arbifyUrl);
      exit(2);
    }

    final apiSecret = _promptInteractiveSecretInstructions(arbifyUrl);
    secret.create(apiSecret);
    secret.ensureGitIgnored();

    return apiSecret;
  }

  void _printNoInteractiveSecretInstructions(Uri arbifyUrl) {
    final createSecretUrl = arbifyUrl.replace(path: '/account/secrets/create');
    print("""
We couldn't find an Arbify secret. Please create a secret using
the URL below, paste it to .secret.arbify file in your project
directory and try again. Don't commit this file to your
version control software.

$createSecretUrl
""");
  }

  String _promptInteractiveSecretInstructions(Uri arbifyUrl) {
    final createSecretUrl = arbifyUrl.replace(path: '/account/secrets/create');
    stdout.write("""
We couldn't find an Arbify secret. Please create a secret using
the URL below, paste it here and press Enter.

$createSecretUrl

Secret: """);
    return stdin.readLineSync();
  }

  void _ensureDirectories() {
    if (!_fileUtils.dirExists()) {
      stdout.write("Output directory doesn't exist. Creating... ");
      _fileUtils.createDir();
      stdout.write('done.\n');
    }
  }

  Future<void> runDownload(Config config) async {
    await _fetchExports(config);
    _saveLocalizationDartFileOrExit();
    _runIntlTranslationGenerateFromArb(config);
  }

  Future<void> _fetchExports(Config config) async {
    final api = ArbifyApi(apiUrl: config.apiUrl, secret: config.apiSecret);
    final arbParser = ArbParser();

    final localArbFiles = _fileUtils.fetch(_arbFilesPattern);

    final availableExports = await api.fetchAvailableExports(config.projectId);
    final availableLocalFiles = Map.fromEntries(
      localArbFiles.map((contents) {
        final arb = arbParser.parseString(contents);

        return MapEntry(arb.locale, arb.lastModified);
      }),
    );

    for (final availableExport in availableExports) {
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

        _fileUtils.put('intl_${availableExport.languageCode}.arb', remoteArb);

        stdout.write('done.\n');
      } else {
        stdout.write('Up-to-date\n');
      }
    }
  }

  void _printApiForbidden(int projectId) {
    print('''
API returned response with a 403 Forbidden status. Make sure you
have access to the project with a project id $projectId and that
you correctly setup the secret. Check .secret.arbify file again.''');
  }

  void _printApiNotFound(int projectId) {
    print('''
API returned response with a 404 Not Found status. Make sure you
put right project id in the pubspec.yaml file. The current
project id is $projectId.''');
  }

  void _saveLocalizationDartFileOrExit() {
    const templateOrder = ['en', 'en-US', 'en-GB'];

    stdout.write('Generating l10n.dart file... ');

    final localFiles = _fileUtils.fetch(_arbFilesPattern);

    final arbParser = ArbParser();
    final locales = <String>[];
    ArbFile template;
    for (final file in localFiles) {
      final arb = arbParser.parseString(file);

      locales.add(arb.locale);

      // Use file with highest priority as a template
      // or the first one as a fallback.
      template ??= arb;

      final fileIndexInOrder = templateOrder.indexOf(arb.locale);
      var templateIndexInOrder = templateOrder.indexOf(template.locale);
      // If the template's language isn't in order list, make its index big
      // so it doesn't prevent from an actual template to override it.
      if (templateIndexInOrder == -1) templateIndexInOrder = 10000;

      if (fileIndexInOrder != -1 && fileIndexInOrder < templateIndexInOrder) {
        template = arb;
      }
    }

    if (template == null) {
      print("fail\nCouldn't find intl_en.arb to use :(");
      exit(4);
    }

    const generator = L10nDartGenerator();
    final l10nDartContents = generator.generate(template, locales);

    _fileUtils.put('l10n.dart', l10nDartContents);

    stdout.write('done\n');
  }

  void _runIntlTranslationGenerateFromArb(Config config) {
    stdout.write('Generating messages dart files... ');

    IntlTranslation().generateFromArb(
      config.outputDir,
      [path.join(config.outputDir, 'l10n.dart')],
      _fileUtils.list(RegExp('intl_(.*).arb')),
    );

    stdout.write('done\n');
  }
}
