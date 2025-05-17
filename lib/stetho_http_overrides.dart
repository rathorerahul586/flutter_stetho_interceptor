import 'dart:io';

import 'package:flutter_stetho_interceptor/stetho_http_client.dart';

/// Custom [HttpOverrides] that wraps the default HttpClient with
/// [StethoHttpClient] to enable HTTP request/response inspection.
///
/// It supports optionally overriding:
/// - How the proxy is selected via [findProxyFromEnvironmentFn].
/// - How the underlying [HttpClient] is created via [createHttpClientFn].
class StethoHttpOverrides extends HttpOverrides {
  /// Optional custom function to determine the proxy based on URL and environment.
  final String Function(Uri url, Map<String, String>? environment)?
  findProxyFromEnvironmentFn;

  /// Optional custom function to create an [HttpClient] instance,
  /// allowing full customization or decorating of the client.
  final HttpClient Function(SecurityContext? context)? createHttpClientFn;

  /// Constructs a [StethoHttpOverrides] with optional hooks for proxy selection
  /// and client creation.
  StethoHttpOverrides({
    this.findProxyFromEnvironmentFn,
    this.createHttpClientFn,
  });

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // Use the custom client creation function if provided,
    // otherwise delegate to the superclass implementation.
    final client =
        createHttpClientFn != null
            ? createHttpClientFn!(context)
            : super.createHttpClient(context);

    // Wrap the client with StethoHttpClient only on Android.
    if (Platform.isAndroid) {
      return StethoHttpClient(client);
    }

    // Return the client as-is for other platforms.
    return client;
  }

  @override
  String findProxyFromEnvironment(Uri url, Map<String, String>? environment) {
    // Use custom proxy selection if provided.
    if (findProxyFromEnvironmentFn != null) {
      return findProxyFromEnvironmentFn!(url, environment);
    } else {
      return super.findProxyFromEnvironment(url, environment);
    }
  }
}
