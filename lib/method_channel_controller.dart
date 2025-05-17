import 'package:flutter/services.dart';
import 'package:flutter_stetho_interceptor/stetho_inspector_request.dart';
import 'package:flutter_stetho_interceptor/stetho_inspector_response.dart';

/// A controller class to bridge Dart and native Android using MethodChannel.
/// This handles communication between Flutter and the Stetho-related logic
/// implemented on the Android native side.
class MethodChannelController {
  // Channel name must match the one registered in Android native plugin.
  static const MethodChannel _channel = MethodChannel('flutter_stetho_interceptor');

  /// Notifies native side that a network request is about to be sent.
  /// Converts [StethoInspectorRequest] to a map before sending.
  static Future<dynamic> requestWillBeSent(StethoInspectorRequest request) =>
      _channel.invokeMethod('requestWillBeSent', request.toMap());

  /// Notifies native side that response headers were received.
  /// Sends a [StethoInspectorResponse] object.
  static Future<dynamic> responseHeadersReceived(
    StethoInspectorResponse response,
  ) => _channel.invokeMethod('responseHeadersReceived', response.toMap());

  /// Instructs native side to interpret a response stream for a given ID.
  static Future<dynamic> interpretResponseStream(String id) =>
      _channel.invokeMethod('interpretResponseStream', id);

  /// Signals that a response stream was read successfully for a given request ID.
  static Future<dynamic> responseReadFinished(String id) =>
      _channel.invokeMethod('responseReadFinished', id);

  /// Signals that an error occurred while reading a response stream.
  /// Expects a list with [requestId, errorMessage].
  static Future<dynamic> responseReadFailed(List<String> idError) =>
      _channel.invokeMethod('responseReadFailed', idError);

  /// Passes a data chunk from Dart to the native stream (used for streamed responses).
  static Future<dynamic> onDataReceived(Map<String, Object> map) =>
      _channel.invokeMethod('onDataReceived', map);

  /// Notifies native that all data for a stream has been sent.
  static Future<dynamic> onDone(String id) =>
      _channel.invokeMethod('onDone', id);

  /// Initializes Stetho on the native side.
  static Future<dynamic> initialize() => _channel.invokeMethod('initialize');
}
