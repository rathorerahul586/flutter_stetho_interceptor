import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stetho_interceptor/flutter_stetho_interceptor.dart';
import 'package:http/http.dart' as http;

void main() {
  // Initialize Stetho only for Android in debug mode.
  FlutterStethoInterceptor.initialize();

  // Run the example app with an injected http.Client.
  runApp(FlutterStethoExample(
    client: http.Client(),
    dioClient: Dio(),
  ));
}

class FlutterStethoExample extends StatelessWidget {
  final http.Client client;
  final Dio dioClient;

  const FlutterStethoExample({
    super.key,
    required this.client,
    required this.dioClient,
  });

  /// Fetches a sample JSON from a public API and logs the response.
  Future<void> fetchJson() async {
    debugPrint('Fetching JSON...');
    try {
      final response = await client.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
        headers: {'Authorization': 'token'}, // Example header
      );
      debugPrint('Response body: ${response.body}');
    } catch (e) {
      debugPrint('Error fetching JSON: $e');
    }
  }

  /// Fetches a sample JSON from a public API and logs the response.
  Future<void> fetchJsonDio() async {
    debugPrint('Fetching JSON Using Dio client...');
    try {
      final response = await dioClient.get(
        'https://jsonplaceholder.typicode.com/posts/1',
        options: Options(headers: {'Authorization': 'token'}),
      );

      debugPrint('Response body: ${response.data}');
    } catch (e) {
      debugPrint('Error fetching JSON: $e');
    }
  }

  /// Fetches an image from the Flutter website.
  Future<void> fetchImage() async {
    debugPrint('Fetching image...');
    try {
      await client.get(
        Uri.parse(
          'https://flutter.dev/assets/404/dash_nest-c64796b59b65042a2b40fae5764c13b7477a592db79eaf04c86298dcb75b78ea.png',
        ),
        headers: {'Authorization': 'token'}, // Example header
      );
      debugPrint('Image fetched');
    } catch (e) {
      debugPrint('Error fetching image: $e');
    }
  }

  /// Attempts to fetch from an invalid URL to demonstrate error handling.
  Future<void> fetchError() async {
    debugPrint('Fetching with error...');
    try {
      await client.get(
        Uri.parse('https://jsonplaceholder.typicode.com/postadsass/1'),
      );
    } catch (e) {
      debugPrint('Expected error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Stetho Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Button to fetch JSON
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: fetchJsonDio,
                  child: const Text('Fetch JSON'),
                ),
              ),
              // Button to fetch Image
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: fetchImage,
                  child: const Text('Fetch Image'),
                ),
              ),
              // Button to fetch an invalid URL to show error handling
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: fetchError,
                  child: const Text('Fetch with Error'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
