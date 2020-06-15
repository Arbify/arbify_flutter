import 'arb_message.dart';

class ArbFile {
  /// [locale] is the locale for which messages/resources are stored
  /// in this file.
  final String locale;

  /// [context] describes (in text) the context in which all these
  /// resources apply.
  final String context;

  /// [lastModified] is the last modified time of this ARB file/data.
  final DateTime lastModified;

  /// [author] is the author of these messages. In the case of localized
  /// ARB files it can contain the names/details of the translator.
  final String author;

  /// [customAttributes] is a map of customized attributes that are
  /// the attributes prefixed with "x-".
  final Map<String, dynamic> customAttributes;

  /// [messages] is a list of messages in this ARB file/data.
  final List<ArbMessage> messages;

  const ArbFile({
    this.locale,
    this.context,
    this.lastModified,
    this.author,
    this.messages = const [],
    this.customAttributes = const {},
  });
}
