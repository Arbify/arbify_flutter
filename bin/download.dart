import 'package:arbify/arbify_download.dart';
import 'package:args/args.dart';
import 'package:universal_io/io.dart';

Future<void> main(List<String> arguments) async {
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

  final ArgResults args = _argParser.parse(arguments);

  if (args['help'] as bool) {
    print('Arbify download command-line utility.\n');
    print(_argParser.usage);
    exit(0);
  }

  await ArbifyCli().run(args);
}
