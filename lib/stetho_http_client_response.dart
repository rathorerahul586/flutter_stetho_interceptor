import 'dart:async';
import 'dart:io';

/// A wrapper around [HttpClientResponse] that proxies all members and
/// wraps the response stream to allow interception or transformation.
///
/// This is typically used to intercept HTTP response data for debugging
/// or inspection purposes (e.g., in Stetho).
class StethoHttpClientResponse extends StreamView<List<int>>
    implements HttpClientResponse {
  /// The underlying HttpClientResponse being wrapped.
  final HttpClientResponse response;

  /// Constructs a new [StethoHttpClientResponse] that wraps [response]
  /// and uses [stream] as the data source for the response body.
  StethoHttpClientResponse(this.response, Stream<List<int>> stream)
    : super(stream);

  // Delegate properties and methods to the underlying response.

  @override
  X509Certificate? get certificate => response.certificate;

  @override
  HttpConnectionInfo? get connectionInfo => response.connectionInfo;

  @override
  int get contentLength => response.contentLength;

  @override
  List<Cookie> get cookies => response.cookies;

  @override
  Future<Socket> detachSocket() {
    return response.detachSocket();
  }

  @override
  HttpHeaders get headers => response.headers;

  @override
  bool get isRedirect => response.isRedirect;

  @override
  bool get persistentConnection => response.persistentConnection;

  @override
  String get reasonPhrase => response.reasonPhrase;

  @override
  List<RedirectInfo> get redirects => response.redirects;

  @override
  int get statusCode => response.statusCode;

  @override
  HttpClientResponseCompressionState get compressionState =>
      response.compressionState;

  @override
  Future<HttpClientResponse> redirect([
    String? method,
    Uri? url,
    bool? followLoops,
  ]) {
    return response.redirect(method, url, followLoops);
  }
}
