// https://www.unicode.org/reports/tr35/#Unicode_language_identifier
import 'package:arbify/src/language_identifier_parser/locale.dart';
import 'package:petitparser/petitparser.dart';

class LanguageIdentifierParser {
  Parser get alphanum => letter() | digit();
  Parser get sep => char('_') | char('-');

  Parser get language =>
      (letter().repeat(2, 3) | letter().repeat(5, 8)).flatten();

  Parser get script => letter().times(4).flatten();
  Parser get region => (letter().times(2) | digit().times(3)).flatten();

  Parser get scriptPart => (sep & script).map((value) => value[1]).optional();
  Parser get regionPart => (sep & region).map((value) => value[1]).optional();

  Parser get id => language & scriptPart & regionPart;

  Locale parse(String text) => id
      .map((value) =>
          Locale(language: value[0], script: value[1], region: value[2]))
      .parse(text)
      .value;
}
