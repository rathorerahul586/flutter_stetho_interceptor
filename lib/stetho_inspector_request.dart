/// Represents an HTTP request captured for inspection by Stetho.
///
/// Contains details about the request such as the URL, method,
/// headers, body, and unique ID.
///
/// The optional [friendlyNameExtra] and [friendlyName] can be used
/// to provide additional context or labeling when displayed in the inspector.
class StethoInspectorRequest {
  /// Optional extra identifier or tag for friendly naming.
  final int? friendlyNameExtra;

  /// The full URL of the request.
  final String url;

  /// The HTTP method (GET, POST, PUT, DELETE, etc.).
  final String method;

  /// The request body as raw bytes.
  final List<int> body;

  /// Unique identifier for correlating requests and responses.
  final String id;

  /// A human-readable name for the request; defaults to 'Flutter Stetho'.
  final String friendlyName;

  /// HTTP headers for the request.
  final Map<String, String> headers;

  /// Constructor for creating a new instance.
  StethoInspectorRequest({
    required this.url,
    required this.method,
    required this.id,
    required this.headers,
    required this.body,
    this.friendlyName = 'Flutter Stetho',
    this.friendlyNameExtra,
  });

  /// Converts this instance to a [Map] for serialization over platform channels.
  Map<String, dynamic> toMap() {
    return {
      'friendlyNameExtra': friendlyNameExtra,
      'url': url,
      'method': method,
      'body': body,
      'id': id,
      'friendlyName': friendlyName,
      'headers': headers,
    };
  }
}
