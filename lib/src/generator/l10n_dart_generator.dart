import '../icu_parser/icu_parser.dart';
import '../arb_parser/arb_file.dart';

class L10nDartGenerator {
  const L10nDartGenerator();

  String generate(ArbFile template, List<String> locales) {
    final localeItems = locales.map((locale) => "\n        '$locale',").join();
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
        messagesBuilder.write("""
        
        desc: '${message.description}',""");
      }

      if (arguments.all.isNotEmpty) {
        final args = arguments.all.keys.join(', ');

        messagesBuilder.write('''
        
        args: [$args],''');
      }

      messagesBuilder.write('\n      );');
    });

    final messages = messagesBuilder.toString();

    return """// File generated with arbify_flutter.
// DO NOT MODIFY BY HAND.
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'messages_all.dart';

class S {
  final String localeName;

  const S(this.localeName);

  static Future<S> load(Locale locale) {
    final name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return S(localeName);
    });
  }

  static S of(BuildContext context) => Localizations.of<S>(context, S);$messages
}

class ArbifyLocalizationsDelegate extends LocalizationsDelegate<S> {
  const ArbifyLocalizationsDelegate();

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
}
