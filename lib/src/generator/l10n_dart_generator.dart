import 'package:arbify/src/language_identifier_parser/locale.dart';
import 'package:arbify/src/language_identifier_parser/locale_parser.dart';

import '../icu_parser/icu_parser.dart';
import '../arb_parser/arb_file.dart';

class L10nDartGenerator {
  const L10nDartGenerator();

  String generate(ArbFile template, List<String> locales) {
    final messagesBuilder = StringBuffer();

    template.messages.forEach((message) {
      final parsedMessage = IcuParser().parse(message.value);
      final messageCode = parsedMessage.toCode();
      final arguments = parsedMessage.arguments;

      String signature;
      if (arguments.all.isEmpty) {
        signature = 'String get ${message.id}';
      } else {
        final args = arguments.all.entries
            .map((arg) => '${arg.value} ${arg.key}')
            .join(', ');

        signature = 'String ${message.id}($args)';
      }

      messagesBuilder.write("""


  $signature => Intl.message(
        '$messageCode',
        name: '${message.id}',""");

      if (message.description != null && message.description.isNotEmpty) {
        final description = message.description.replaceAll("'", r"\'");

        messagesBuilder.write("""
        
        desc: '${description}',""");
      }

      if (arguments.all.isNotEmpty) {
        final args = arguments.all.keys.join(', ');

        messagesBuilder.write('''
        
        args: [$args],''');
      }

      messagesBuilder.write('\n      );');
    });

    final messages = messagesBuilder.toString();

    final parsedLocales = locales
        .map((locale) => LanguageIdentifierParser().parse(locale))
        .toList();
    final supportedLocales = _generateSupportedLocalesArray(parsedLocales);
    final localeItems =
        parsedLocales.map((locale) => "\n        '${locale.language}',").join();

    return """// File generated with arbify_flutter.
// DO NOT MODIFY BY HAND.
// ignore_for_file: lines_longer_than_80_chars, non_constant_identifier_names
// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'messages_all.dart';

class S {
  final String localeName;

  const S(this.localeName);

  static const delegate = ArbifyLocalizationsDelegate();

  static Future<S> load(Locale locale) {
    final localeName = Intl.canonicalizedLocale(locale.toString());

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return S(localeName);
    });
  }

  static S of(BuildContext context) => Localizations.of<S>(context, S);$messages
}

class ArbifyLocalizationsDelegate extends LocalizationsDelegate<S> {
  const ArbifyLocalizationsDelegate();

  List<Locale> get supportedLocales => [
$supportedLocales  ];

  @override
  bool isSupported(Locale locale) => [$localeItems
      ].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) => S.load(locale);

  @override
  bool shouldReload(ArbifyLocalizationsDelegate old) => false;
}
""";
  }

  String _generateSupportedLocalesArray(List<Locale> locales) {
    final supportedLocales = StringBuffer();

    locales.forEach((locale) {
      final languageCode = "languageCode: '${locale.language}'";
      final scriptCode =
          locale.script == null ? '' : ", scriptCode: '${locale.script}'";
      final countryCode =
          locale.script == null ? '' : ", countryCode: '${locale.region}'";

      supportedLocales.writeln(
          '        Locale.fromSubtags($languageCode$scriptCode$countryCode),');
    });

    return supportedLocales.toString();
  }
}
