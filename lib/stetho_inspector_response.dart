/// Represents an HTTP response captured for inspection by Stetho.
///
/// Contains details about the response such as URL, status code,
/// headers, connection information, and the corresponding request ID.
class StethoInspectorResponse {
  /// The URL associated with this response.
  final String url;

  /// Indicates if the connection was reused for this response.
  final bool connectionReused;

  /// An identifier for the connection used.
  final int connectionId;

  /// Indicates if the response was served from disk cache.
  final bool fromDiskCache;

  /// The unique ID of the request corresponding to this response.
  final String requestId;

  /// The HTTP status code (e.g., 200, 404).
  final int statusCode;

  /// The reason phrase associated with the status code (e.g., "OK").
  final String reasonPhrase;

  /// HTTP headers included in the response.
  final Map<String, String> headers;

  /// Constructs a new instance with all required fields.
  ///
  /// [fromDiskCache] defaults to false if not provided.
  StethoInspectorResponse({
    required this.url,
    required this.connectionReused,
    required this.connectionId,
    required this.requestId,
    required this.statusCode,
    required this.reasonPhrase,
    required this.headers,
    this.fromDiskCache = false,
  });

  /// Converts this instance to a [Map] for serialization over platform channels.
  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'connectionReused': connectionReused,
      'connectionId': connectionId,
      'fromDiskCache': fromDiskCache,
      'requestId': requestId,
      'statusCode': statusCode,
      'reasonPhrase': reasonPhrase,
      'headers': headers,
    };
  }
}
