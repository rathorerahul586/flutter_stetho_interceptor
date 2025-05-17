import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_stetho_interceptor_method_channel.dart';

abstract class FlutterStethoInterceptorPlatform extends PlatformInterface {
  /// Constructs a FlutterStethoInterceptorPlatform.
  FlutterStethoInterceptorPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterStethoInterceptorPlatform _instance = MethodChannelFlutterStethoInterceptor();

  /// The default instance of [FlutterStethoInterceptorPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterStethoInterceptor].
  static FlutterStethoInterceptorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterStethoInterceptorPlatform] when
  /// they register themselves.
  static set instance(FlutterStethoInterceptorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
