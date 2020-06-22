import 'package:arbify/src/language_identifier_parser/locale_parser.dart';
import 'package:test/test.dart';

void main() {
  test('parses en-US', () {
    final locale = LanguageIdentifierParser().parse('en-US');
    expect(locale.language, equals('en'));
    expect(locale.script, isNull);
    expect(locale.region, equals('US'));
  });

  test('parses en_GB', () {
    final locale = LanguageIdentifierParser().parse('en_GB');
    expect(locale.language, equals('en'));
    expect(locale.script, isNull);
    expect(locale.region, equals('GB'));
  });

  test('parses es-419', () {
    final locale = LanguageIdentifierParser().parse('es-419');
    expect(locale.language, equals('es'));
    expect(locale.script, isNull);
    expect(locale.region, equals('419'));
  });

  test('parses uz-Cyrl', () {
    final locale = LanguageIdentifierParser().parse('uz-Cyrl');
    expect(locale.language, equals('uz'));
    expect(locale.script, equals('Cyrl'));
    expect(locale.region, isNull);
  });

  test('parses zn-Hans-TW', () {
    final locale = LanguageIdentifierParser().parse('zn-Hans-TW');
    expect(locale.language, equals('zn'));
    expect(locale.script, equals('Hans'));
    expect(locale.region, equals('TW'));
  });
}
