import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_stetho_interceptor/stetho_http_client_response.dart';
import 'package:flutter_stetho_interceptor/stetho_inspector_response.dart';
import 'package:flutter_stetho_interceptor/utils.dart';

import 'method_channel_controller.dart';

/// A wrapper around [HttpClientRequest] that intercepts outgoing request
/// data and relays it to the Stetho debugging infrastructure.
///
/// It buffers written data via a broadcast stream and sends
/// request/response information over a method channel to the native side.
class StethoHttpClientRequest implements HttpClientRequest {
  final HttpClientRequest request;

  /// Unique identifier for this request (used for matching with responses).
  final String id;

  /// Stream controller that broadcasts chunks of request body data.
  final StreamController<List<int>> _streamController =
      StreamController<List<int>>.broadcast();

  /// Exposes the broadcast stream of body data chunks.
  Stream<List<int>> get stream => _streamController.stream;

  StethoHttpClientRequest(this.request, this.id);

  /// Adds bytes to the request body, forwarding to both the underlying
  /// request and the internal stream controller for tracking.
  @override
  void add(List<int> data) {
    _streamController.add(data);
    request.add(data);
  }

  /// Adds a stream of byte chunks to the request body.
  ///
  /// Each chunk is forwarded to the internal stream controller and the
  /// underlying request.
  @override
  Future<void> addStream(Stream<List<int>> stream) {
    // Broadcast the incoming stream so multiple listeners can subscribe.
    final newStream = stream.asBroadcastStream();

    // Listen and add each chunk to the internal stream controller.
    newStream.listen((chunk) => _streamController.add(chunk));

    // Forward the stream to the actual request.
    return request.addStream(newStream);
  }

  /// Completes the request and intercepts the response.
  ///
  /// Sends the response headers to the native side, triggers interpretation
  /// of the response stream, and returns a wrapped response that tracks the
  /// response data.
  @override
  Future<HttpClientResponse> close() async {
    final response = await request.close();

    // Notify the native side of response headers and metadata.
    MethodChannelController.responseHeadersReceived(
      StethoInspectorResponse(
        url: request.uri.toString(),
        statusCode: response.statusCode,
        requestId: id,
        headers: headersToMap(response.headers),
        connectionReused: false,
        reasonPhrase: response.reasonPhrase,
        connectionId: id.hashCode,
      ),
    );

    // Request native side to interpret the response stream.
    MethodChannelController.interpretResponseStream(id);

    // Return a wrapped response that intercepts the response body.
    return StethoHttpClientResponse(
      response,
      response.transform(createResponseTransformer(id)),
    );
  }

  // --------------------------------------------------------------------------
  // The following getters/setters simply proxy to the underlying request.
  // --------------------------------------------------------------------------

  @override
  bool get bufferOutput => request.bufferOutput;

  @override
  set bufferOutput(bool bufferOutput) => request.bufferOutput = bufferOutput;

  @override
  int get contentLength => request.contentLength;

  @override
  set contentLength(int contentLength) => request.contentLength = contentLength;

  @override
  Encoding get encoding => request.encoding;

  @override
  set encoding(Encoding encoding) => request.encoding = encoding;

  @override
  bool get followRedirects => request.followRedirects;

  @override
  set followRedirects(bool followRedirects) =>
      request.followRedirects = followRedirects;

  @override
  int get maxRedirects => request.maxRedirects;

  @override
  set maxRedirects(int maxRedirects) => request.maxRedirects = maxRedirects;

  @override
  bool get persistentConnection => request.persistentConnection;

  @override
  set persistentConnection(bool persistentConnection) =>
      request.persistentConnection = persistentConnection;

  @override
  HttpConnectionInfo? get connectionInfo => request.connectionInfo;

  @override
  List<Cookie> get cookies => request.cookies;

  @override
  Future<HttpClientResponse> get done => request.done;

  @override
  Future<void> flush() => request.flush();

  @override
  HttpHeaders get headers => request.headers;

  @override
  String get method => request.method;

  @override
  Uri get uri => request.uri;

  // --------------------------------------------------------------------------
  // Override write methods to capture data written as text/characters.
  // --------------------------------------------------------------------------

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    request.writeAll(objects, separator);

    // Concatenate and add string data to the stream controller.
    final data = objects.map((obj) => obj.toString()).join(separator);
    _streamController.add(utf8.encode(data));
  }

  @override
  void writeCharCode(int charCode) {
    request.writeCharCode(charCode);
    _streamController.add([charCode]);
  }

  @override
  void writeln([Object? obj = ""]) {
    request.writeln(obj);
    final data = obj?.toString() ?? "";
    _streamController.add(utf8.encode(data));
  }

  @override
  void write(Object? obj) {
    request.write(obj);

    if (obj != null) {
      _streamController.add(utf8.encode(obj.toString()));
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    request.addError(error, stackTrace);
  }

  /// TODO: Implement abort logic if needed.
  @override
  void abort([Object? exception, StackTrace? stackTrace]) {
    // Not implemented yet.
  }
}
