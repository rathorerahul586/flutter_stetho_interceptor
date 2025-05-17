import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'method_channel_controller.dart';

/// Creates a [StreamTransformer] that intercepts HTTP response data,
/// forwarding chunks to the platform via the method channel while
/// continuing to pass the data downstream.
///
/// This allows the native side (e.g., Chrome DevTools) to inspect
/// HTTP response streams in real-time.
StreamTransformer<List<int>, List<int>> createResponseTransformer(String id) {
  return StreamTransformer.fromHandlers(
    handleData: (data, sink) {
      // Forward data downstream
      sink.add(data);

      // Notify native side of new data chunk
      MethodChannelController.onDataReceived({"data": data, "id": id});
    },
    handleError: (error, stacktrace, sink) {
      // Forward error downstream
      sink.addError(error, stacktrace);

      // Notify native side of read failure
      MethodChannelController.responseReadFailed([id, error.toString()]);
    },
    handleDone: (sink) {
      // Close downstream sink
      sink.close();

      // Notify native side that the response has finished reading
      MethodChannelController.responseReadFinished(id);
      MethodChannelController.onDone(id);
    },
  );
}

/// Converts an [HttpHeaders] instance into a [Map] suitable for
/// sending over platform channels or displaying in Chrome DevTools.
///
/// Only the first header value for each key is preserved.
/// Headers are case-sensitive; an explicit 'Content-Type' key is
/// duplicated to match Chrome DevTools expectations.
Map<String, String> headersToMap(HttpHeaders headers) {
  final Map<String, String> map = {};

  headers.forEach((header, values) {
    // Take only the first value for each header key
    map[header] = values.first;

    // Add an explicit capitalized Content-Type header as Chrome expects
    if (header.toLowerCase() == 'content-type') {
      map['Content-Type'] = values.first;
    }
  });

  return map;
}

/// Generates random version 4 UUID strings compliant with RFC 4122.
///
/// Useful for generating unique request/response IDs for tracking
/// in debugging or logging contexts.
///
/// Example output: `f47ac10b-58cc-4372-a567-0e02b2c3d479`
class Uuid {
  final Random _random = Random();

  /// Generates a random v4 UUID string.
  ///
  /// The UUID format is 8-4-4-4-12 hex digits, with the
  /// version and variant bits set according to the spec.
  String generateV4() {
    // Generate variant (y) bits: 8, 9, A, or B
    final int special = 8 + _random.nextInt(4);

    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-' // 8 hex digits
        '${_bitsDigits(16, 4)}-' // 4 hex digits
        '4${_bitsDigits(12, 3)}-' // '4' + 3 hex digits (version 4)
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-' // variant + 3 hex digits
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}'; // 12 hex digits
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}
