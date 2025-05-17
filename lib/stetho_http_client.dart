import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_stetho_interceptor/stetho_http_client_request.dart';
import 'package:flutter_stetho_interceptor/stetho_inspector_request.dart';
import 'package:flutter_stetho_interceptor/utils.dart';

import 'method_channel_controller.dart';

/// A custom [HttpClient] wrapper that intercepts and tracks HTTP requests
/// to facilitate Stetho debugging support.
///
/// Wraps a base [HttpClient] instance and intercepts request creation,
/// forwarding details to the native side via [MethodChannelController].
class StethoHttpClient implements HttpClient {
  final HttpClient client;

  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(seconds: 120);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  StethoHttpClient(this.client);

  // Proxy all credential-related methods directly to the underlying client

  @override
  void addCredentials(
    Uri url,
    String realm,
    HttpClientCredentials credentials,
  ) {
    client.addCredentials(url, realm, credentials);
  }

  @override
  void addProxyCredentials(
    String host,
    int port,
    String realm,
    HttpClientCredentials credentials,
  ) {
    client.addProxyCredentials(host, port, realm, credentials);
  }

  @override
  set authenticate(
    Future<bool> Function(Uri url, String scheme, String? realm)? f,
  ) {
    client.authenticate = f;
  }

  @override
  set authenticateProxy(
    Future<bool> Function(String host, int port, String scheme, String? realm)?
    f,
  ) {
    client.authenticateProxy = f;
  }

  @override
  set badCertificateCallback(
    bool Function(X509Certificate cert, String host, int port)? callback,
  ) {
    client.badCertificateCallback = callback;
  }

  @override
  void close({bool force = false}) {
    client.close(force: force);
  }

  @override
  set connectionFactory(
    Future<ConnectionTask<Socket>> Function(
      Uri url,
      String? proxyHost,
      int? proxyPort,
    )?
    f,
  ) {
    // ❗ Not yet implemented. You may forward this to `client.connectionFactory` if needed.
  }

  @override
  set findProxy(String Function(Uri url)? f) => client.findProxy = f;

  @override
  set keyLog(Function(String line)? callback) {
    // ❗ Not implemented. Relevant mainly for SSL/TLS debugging.
  }

  // Forward open/delete/get/etc to a centralized open/openUrl implementation

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) =>
      open("DELETE", host, port, path);

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => openUrl("DELETE", url);

  @override
  Future<HttpClientRequest> get(String host, int port, String path) =>
      open("GET", host, port, path);

  @override
  Future<HttpClientRequest> getUrl(Uri url) => openUrl("GET", url);

  @override
  Future<HttpClientRequest> head(String host, int port, String path) =>
      open("HEAD", host, port, path);

  @override
  Future<HttpClientRequest> headUrl(Uri url) => openUrl("HEAD", url);

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) =>
      open("PATCH", host, port, path);

  @override
  Future<HttpClientRequest> patchUrl(Uri url) => openUrl("PATCH", url);

  @override
  Future<HttpClientRequest> post(String host, int port, String path) =>
      open("POST", host, port, path);

  @override
  Future<HttpClientRequest> postUrl(Uri url) => openUrl("POST", url);

  @override
  Future<HttpClientRequest> put(String host, int port, String path) =>
      open("PUT", host, port, path);

  @override
  Future<HttpClientRequest> putUrl(Uri url) => openUrl("PUT", url);

  /// Opens an HTTP request by method, host, port, and path.
  ///
  /// Constructs a URI and delegates to [openUrl].
  @override
  Future<HttpClientRequest> open(
    String method,
    String host,
    int port,
    String path,
  ) async {
    final uri = Uri(host: host, port: port, path: path);
    return openUrl(method, uri);
  }

  /// Opens an HTTP request by method and URI.
  ///
  /// Intercepts the request to attach a unique ID and to track the request
  /// body, forwarding request details to the native side using
  /// [MethodChannelController].
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    return client.openUrl(method, url).then((request) {
      final wrapped = _wrapResponse(request);
      final body = <int>[]; // Buffer to capture the request body bytes

      // For non-body methods (GET, HEAD, DELETE, etc.), notify immediately
      if (method.toUpperCase() != 'POST' && method.toUpperCase() != 'PUT') {
        scheduleMicrotask(() {
          MethodChannelController.requestWillBeSent(
            StethoInspectorRequest(
              url: request.uri.toString(),
              headers: headersToMap(request.headers),
              method: request.method,
              id: wrapped.id,
              body: body,
              friendlyNameExtra: null,
            ),
          );
        });
      } else {
        // For POST/PUT, listen to the request stream to capture the body progressively
        wrapped.stream.listen((chunk) {
          body.addAll(chunk);
          scheduleMicrotask(() {
            debugPrint("requestWillBeSent - ${request.uri}");
            MethodChannelController.requestWillBeSent(
              StethoInspectorRequest(
                url: request.uri.toString(),
                headers: headersToMap(request.headers),
                method: request.method,
                id: wrapped.id,
                body: body,
              ),
            );
          });
        });
      }

      return wrapped;
    });
  }

  /// Wraps an [HttpClientRequest] with a unique ID for tracking.
  ///
  /// Returns a [StethoHttpClientRequest] that proxies the original request.
  StethoHttpClientRequest _wrapResponse(HttpClientRequest request) {
    final id = Uuid().generateV4(); // Use your UUID generator here
    return StethoHttpClientRequest(request, id);
  }
}
