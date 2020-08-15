import 'dart:convert';

import 'arb_file.dart';
import 'arb_message.dart';

class ArbParser {
  ArbFile parseString(String content) {
    final json = jsonDecode(content) as Map<String, dynamic>;

    final messages = <ArbMessage>[];
    json.forEach((key, value) {
      if (key.startsWith('@')) {
        return;
      }

      final attributes = json['@$key'] as Map<String, dynamic>;
      final message = parseMessage(key, value as String, attributes);

      messages.add(message);
    });

    final file = ArbFile(
      messages: messages,
      locale: json['@@locale'] as String,
      context: json['@@context'] as String,
      lastModified: DateTime.tryParse(json['@@last_modified'] as String),
      author: json['@@author'] as String,
    );

    return file;
  }

  ArbMessage parseMessage(
    String id,
    String value,
    Map<String, dynamic> attributes,
  ) {
    final attrs = attributes ?? {};

    final customAttributes = parseCustomAttributes(attrs);
    final message = ArbMessage(
      id: id,
      value: value,
      type: attrs['type'] as String,
      context: attrs['context'] as String,
      description: attrs['description'] as String,
      placeholders: attrs['placeholders'] as Map<String, Map<String, String>>,
      screenshot: attrs['screenshot'] as String,
      video: attrs['video'] as String,
      sourceText: attrs['source_text'] as String,
      customAttributes: customAttributes,
    );

    return message;
  }

  Map<String, dynamic> parseCustomAttributes(Map<String, dynamic> attributes) {
    final entries = attributes.entries
        .where((attribute) => attribute.key.startsWith('x-'))
        .map((attribute) => MapEntry(
              attribute.key.substring(2),
              attribute.value,
            ));

    return Map.fromEntries(entries);
  }
}
