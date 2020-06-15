import 'dart:io';

import 'package:path/path.dart' as path;
import '../arb_parser/arb_file.dart';

class L10nDartGenerator {
  L10nDartGenerator();

  String generate(ArbFile template, List<String> locales) {
    final localeItems = locales.map((locale) => "\n        '$locale',").join();
    final messagesBuilder = StringBuffer();

    template.messages.forEach((message) {
      // TODO: Support for plural, gender, select.
      messagesBuilder.write("""


  String get ${message.id} => Intl.message(
        '${message.value}',
        name: '${message.id}',""");

      if (message.description != null && message.description.isNotEmpty) {
        messagesBuilder.write("""
        
        description: '${message.description}',""");
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

    return initializeMessages(localeName).then((_) => S(localeName));
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
