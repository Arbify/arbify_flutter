import 'package:meta/meta.dart';

// https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification
class ArbMessage {
  /// [id] is the resource id is the identifier for the resource in a given
  /// name space. Its naming should follow the convention for constant string
  /// in the target language. Because the naming is local to name space,
  /// developers only need to avoid name collision within the scope
  /// of name space.
  ///
  ///     "MSG_HELLO":  "Hello",
  ///     "title": "My application"
  ///
  /// In the above example, "MSG_HELLO" and "title" are both resource IDs.
  ///
  /// Resource id for HTML has a special convention "elem_id@attribute_name"
  /// as shown in the following example.
  ///
  ///     "logo-image@src": "images/mylogo.jpg",
  ///     "logo-image@alt": "my logo"
  final String id;

  /// [type] describes the type of resource. Possible values are "text",
  /// "image", "css". Program should not rely on this attribute in run time.
  /// It is mainly for the localization tools.
  final String type;

  /// [context] describes (in text) the context in which this resource applies.
  /// Context is organized in hierarchy, and level separated by ":".
  /// Tools can use this information to restore the tree structure
  /// from ARB’s flat layout. When this piece of information is missing,
  /// it defaults to global.
  ///
  /// Example:
  ///
  ///     "context":"homePage:Print dialog box"
  final String context;

  /// [description] is a short paragraph describing the resource and how it is
  /// being used by the app, and message that need to be passed to
  /// localization process and translators.
  final String description;

  /// [placeholders] is a map from placeholder id to placeholder properties,
  /// including description and example. Placeholder can be specified using
  /// number (as in "{0}") or name (as in "{num}"). Number starts from 0
  /// and the corresponding argument(s) are passed directly as function
  /// arguments. Named arguments are provided through an map object that maps
  /// each name to its value.
  ///
  /// A string in a valid placeholder syntax will be interpreted as literal
  /// string if no valid replacement argument provided. ARB has not escape
  /// mechanism. Developer can always choose to use different argument name
  /// to keep certain string as literal. For example, in "{apple} is
  /// delicious.", as long as "apple" is not used as variable name in message
  /// construction call, it will be interpreted as literal.
  ///
  /// For ARB processing tools, as it has no idea how a message will be used,
  /// it needs to get this information from attributes. For this purpose,
  /// we have 2 important rules,
  ///
  /// 1. All placeholders in valid syntax should be interpreted as placeholder
  /// if there is no "placeholders" property in attributes.
  /// 2. A placeholder in valid syntax will be treated as literal if
  /// the messages does has "placeholders" property, but the placeholder has
  /// no corresponding entry in "placeholders" map. In other words,
  /// if "placeholders" property is available, it must be complete. This rule
  /// applies to the special placeholder syntax "{@string}" as well.
  ///
  /// A message cannot use both at the same time.
  ///
  /// Example:
  ///
  ///     "CURR_LOCALE": "current locale is {0}.",
  ///     "@CURR_LOCALE": {
  ///       "placeholders": {
  ///         "0": {
  ///           "description": "current locale name.",
  ///           "example": "zh"
  ///         }
  ///       }
  ///     },
  ///
  ///     "NON_PLACEHOLDER": "{0} is a literal.",
  ///     "@NON_PLACEHOLDER": {
  ///       "placeholders": {
  ///       }
  ///     },
  ///
  ///     "TRANSLATE": "Translate from {source} to {target}",
  ///     "@TRANSLATE": {
  ///       "placeholders": {
  ///         "source": {
  ///           "description": "source locale name",
  ///           "example": "en_US"
  ///         },
  ///         "target": {
  ///           "description": "target locale name",
  ///           "example": "ja_JP"
  ///         }
  ///       }
  ///     },
  final Map<String, Map<String, String>> placeholders;

  /// [screenshot] is a URL to the image location or base-64 encoded image
  /// data.
  final String screenshot;

  /// [video] is a URL to a video of the app/resource/widget in action.
  final String video;

  /// [sourceText] is the source of the text from where this message is
  /// translated from. This is used to track source arb change and determine
  /// if this message need to be updated.
  final String sourceText;

  /// [customAttributes] is a map of customized attributes that are
  /// the attributes prefixed with "x-".
  final Map<String, dynamic> customAttributes;

  /// Resource values ([value]) in an ARB file is always in the form of
  /// a string. Most of those strings represent translatable text. Some strings
  /// could be urls, or represent other type of data like image or audio.
  /// To present those data that is binary in nature, data url (refer to
  /// RFC 2397) is used in ARB format. For example, in the sample resource file
  /// above, the value for the resource ID "screen" is specified as a data url.
  final String value;

  ArbMessage({
    @required this.id,
    this.type,
    this.context,
    this.description,
    this.placeholders,
    this.screenshot,
    this.video,
    this.sourceText,
    this.customAttributes,
    @required this.value,
  });
}
