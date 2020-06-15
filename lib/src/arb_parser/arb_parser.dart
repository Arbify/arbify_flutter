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
      final message = parseMessage(key, value, attributes);

      messages.add(message);
    });

    final file = ArbFile(
      messages: messages,
      locale: json['@@locale'],
      context: json['@@context'],
      lastModified: DateTime.tryParse(json['@@last_modified']),
      author: json['@@author'],
    );

    return file;
  }

  ArbMessage parseMessage(
    String id,
    String value,
    Map<String, dynamic> attributes,
  ) {
    attributes ??= {};

    final customAttributes = parseCustomAttributes(attributes);
    final message = ArbMessage(
      id: id,
      value: value,
      type: attributes['type'],
      context: attributes['context'],
      description: attributes['description'],
      placeholders: attributes['placeholders'],
      screenshot: attributes['screenshot'],
      video: attributes['video'],
      sourceText: attributes['source_text'],
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
