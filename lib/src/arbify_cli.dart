import 'package:arbify/src/api/arbify_api.dart';
import 'package:arbify/src/arb_parser/arb_parser.dart';
import 'package:arbify/src/config/pubspec_config.dart';
import 'package:arbify/src/config/secret.dart';
import 'package:arbify/src/output_file_utils.dart';
import 'package:arbify/src/print_instructions.dart';
import 'package:args/args.dart';
import 'package:dio/dio.dart';
import 'package:intl_utils/intl_utils.dart';
import 'package:universal_io/io.dart';

class ArbifyCli {
  late final OutputFileUtils _fileUtils;
  final _arbFilesPattern = RegExp(r'intl_(.*)\.arb');

  Future<void> run(ArgResults args) async {
    final pubspec = PubspecConfig.fromPubspec();
    if (pubspec.url == null || pubspec.projectId == null) {
      PrintInstructions.pubspec();
      exit(1);
    }
    final interactive = args['interactive'] as bool;
    final Uri apiUrl = pubspec.url!;
    final int projectId = pubspec.projectId!;
    final String outputDir = pubspec.outputDir ?? 'lib/l10n';

    final secret = Secret();

    final String apiSecret;
    final overrideSecret = args['secret'] as String?;

    if (overrideSecret != null) {
      apiSecret = overrideSecret;
    } else if (secret.exists()) {
      apiSecret = secret.value();
    } else if (!interactive) {
      PrintInstructions.noInteractiveSecret(apiUrl);
      exit(2);
    } else {
      apiSecret = PrintInstructions.promptInteractiveSecret(apiUrl);
      secret.create(apiSecret);
      secret.ensureGitIgnored();
    }

    _fileUtils = OutputFileUtils(outputDir: outputDir);

    if (!_fileUtils.dirExists()) {
      stdout.write("Output directory doesn't exist. Creating... ");
      _fileUtils.createDir();
      stdout.write('done.\n');
    }

    try {
      final api = ArbifyApi(apiUrl: apiUrl, secret: apiSecret);
      final availableExports =
          await api.fetchAvailableExportsForProj(projectId);

      final arbParser = ArbParser();
      final localArbFiles = _fileUtils.fetch(_arbFilesPattern);
      final availableLocalFiles = Map.fromEntries(
        localArbFiles.map((contents) {
          final arb = arbParser.parseArbFile(contents);

          return MapEntry(arb.locale, arb.lastModified);
        }),
      );

      for (final availableExport in availableExports) {
        stdout.write(availableExport.languageCode.padRight(20));

        final DateTime? localFileLastModified =
            availableLocalFiles[availableExport.languageCode];

        /// If there is no local file for a given export or if it's older
        /// than the available export, download it.
        if (localFileLastModified == null ||
            localFileLastModified.isBefore(availableExport.lastModified)) {
          stdout.write('Downloading... ');

          final remoteArb = await api.fetchExport(
            projectId: projectId,
            languageCode: availableExport.languageCode,
          );

          _fileUtils.put('intl_${availableExport.languageCode}.arb', remoteArb);

          stdout.write('done.\n');
        } else {
          stdout.write('Up-to-date\n');
        }
      }

      stdout.write('Generating messages dart files... ');
      await Generator().generateAsync();
      stdout.write('done\n');
    } on DioError catch (e) {
      if (e.type == DioErrorType.response) {
        if (e.response?.statusCode == 403) {
          PrintInstructions.apiForbidden(projectId);
        } else if (e.response?.statusCode == 404) {
          PrintInstructions.apiNotFound(projectId);
        } else {
          print('API exception\n');
          print(e.toString());
        }
      } else {
        print('Exception while communicating with the Arbify '
            'at ${apiUrl.toString()}\n');
        print(e.toString());
      }

      exit(3);
    }
  }
}
