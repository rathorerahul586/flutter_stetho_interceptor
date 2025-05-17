import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stetho_interceptor/flutter_stetho_interceptor.dart';
import 'package:flutter_stetho_interceptor/flutter_stetho_interceptor_platform_interface.dart';
import 'package:flutter_stetho_interceptor/flutter_stetho_interceptor_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterStethoInterceptorPlatform
    with MockPlatformInterfaceMixin
    implements FlutterStethoInterceptorPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterStethoInterceptorPlatform initialPlatform = FlutterStethoInterceptorPlatform.instance;

  test('$MethodChannelFlutterStethoInterceptor is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterStethoInterceptor>());
  });

  test('getPlatformVersion', () async {
    FlutterStethoInterceptor flutterStethoInterceptorPlugin = FlutterStethoInterceptor();
    MockFlutterStethoInterceptorPlatform fakePlatform = MockFlutterStethoInterceptorPlatform();
    FlutterStethoInterceptorPlatform.instance = fakePlatform;

    expect(await flutterStethoInterceptorPlugin.getPlatformVersion(), '42');
  });
}
