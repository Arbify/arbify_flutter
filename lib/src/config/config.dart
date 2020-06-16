import 'package:meta/meta.dart';

class Config {
  /// The url of an Arbify instance.
  final Uri apiUrl;

  /// The id of a project.
  final int projectId;

  /// The secret to use for authentication.
  final String apiSecret;

  /// The directory to output results to.
  final String outputDir;

  const Config({
    @required this.apiUrl,
    @required this.projectId,
    @required this.apiSecret,
    @required this.outputDir,
  });
}
