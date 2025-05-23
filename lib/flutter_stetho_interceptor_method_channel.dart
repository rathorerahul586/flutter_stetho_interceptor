import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_stetho_interceptor_platform_interface.dart';

/// An implementation of [FlutterStethoInterceptorPlatform] that uses method channels.
class MethodChannelFlutterStethoInterceptor extends FlutterStethoInterceptorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_stetho_interceptor');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
