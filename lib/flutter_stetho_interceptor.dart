import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stetho_interceptor/stetho_http_overrides.dart';

import 'method_channel_controller.dart';

/// A static utility class for initializing Stetho support in a Flutter application.
///
/// This sets up a global [HttpOverrides] to enable HTTP request interception,
/// and relays those requests to the native side using [MethodChannelController].
///
/// ⚠️ This should only be used in development or debug builds unless explicitly allowed.
///
/// ### Example Usage:
/// ```dart
/// void main() {
///   FlutterStethoInterceptor.initialize(); // Initialize Stetho for Android
///   runApp(MyApp());
/// }
/// ```
class FlutterStethoInterceptor {
  /// Initializes the Stetho debugging bridge for Android.
  ///
  /// This method:
  /// - Ensures Flutter bindings are initialized
  /// - Sets a custom [HttpOverrides] for request tracking
  /// - Delegates initialization to native Android via [MethodChannelController]
  ///
  /// Only runs on Android by default in debug mode.
  ///
  /// [allowInReleaseMode] - Optional flag to allow initialization in release builds (not recommended).
  static Future<void> initialize({bool allowInReleaseMode = false}) async {
    if (Platform.isAndroid && (allowInReleaseMode || !kReleaseMode)) {
      // Ensure Flutter engine is ready before plugin registration
      WidgetsFlutterBinding.ensureInitialized();

      // Override global HTTP behavior to intercept requests
      HttpOverrides.global = StethoHttpOverrides();

      // Trigger native-side Stetho setup
      return MethodChannelController.initialize();
    } else {
      debugPrint(
        'FlutterStethoInterceptor.initialize() was called on an unsupported platform or in release mode. Initialization skipped.',
      );
    }
  }
}
