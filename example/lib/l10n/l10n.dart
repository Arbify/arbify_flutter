// File generated with arbify_flutter.
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

  static S of(BuildContext context) => Localizations.of<S>(context, S);

  String get app_title => Intl.message(
        'Flutter Demo!',
        name: 'app_title',
      );

  String counter_message(num count) => Intl.message(
        '${Intl.plural(count, one: 'You clicked the button only 1 time!', other: 'You clicked the button ${count} times!', args: [count])}',
        name: 'counter_message',        
        args: [count],
      );

  String get increment_tooltip => Intl.message(
        'Increment',
        name: 'increment_tooltip',
      );
}

class ArbifyLocalizationsDelegate extends LocalizationsDelegate<S> {
  const ArbifyLocalizationsDelegate();

  List<Locale> get supportedLocales => [
        Locale.fromSubtags(languageCode: 'en'),
        Locale.fromSubtags(languageCode: 'pl'),
  ];

  @override
  bool isSupported(Locale locale) => [
        'en',
        'pl',
      ].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) => S.load(locale);

  @override
  bool shouldReload(ArbifyLocalizationsDelegate old) => false;
}
