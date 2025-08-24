import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController webViewController;
  String webViewMessage = 'No messages yet';
  int buttonClickCount = 0;

  @override
  void initState() {
    super.initState();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (JavaScriptMessage message) {
          print('=== FLUTTER RECEIVED MESSAGE ===');
          print('Raw message: ${message.message}');
          try {
            // Parse the message from WebView
            final data = _parseMessage(message.message);
            if (data != null) {
              setState(() {
                if (data['type'] == 'buttonClick') {
                  buttonClickCount = data['count'] ?? 0;
                  webViewMessage = data['message'] ?? 'Button clicked';
                  print('Button clicked! Count: $buttonClickCount');
                } else if (data['type'] == 'message') {
                  webViewMessage = '${data['type']}: ${data['content']}';
                  print('Message received: ${data['content']}');
                } else if (data['type'] == 'ready') {
                  webViewMessage = 'WebView is ready';
                  print('WebView ready message received');
                }
              });
              print('Successfully processed message: $data');
            } else {
              print('Failed to parse message');
            }
          } catch (e) {
            print('Error processing message: $e');
          }
          print('=== END MESSAGE PROCESSING ===');
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print('WebView loading: $progress%');
          },
          onPageFinished: (String url) {
            print('WebView loaded: $url');
          },
        ),
      )
      ..loadFlutterAsset('assets/index.html');
  }

  Map<String, dynamic>? _parseMessage(String message) {
    try {
      print('Attempting to parse message: $message');
      // Try to parse as JSON first
      final data = Map<String, dynamic>.from(jsonDecode(message) as Map);
      print('Successfully parsed JSON: $data');
      return data;
    } catch (e) {
      print('JSON parsing failed, trying simple parsing: $e');
      // Fallback to simple parsing
      if (message.startsWith('{') && message.endsWith('}')) {
        final cleanMessage = message.trim();
        final data = <String, dynamic>{};

        if (cleanMessage.contains('"type"')) {
          if (cleanMessage.contains('"buttonClick"')) {
            data['type'] = 'buttonClick';
            if (cleanMessage.contains('"count"')) {
              final countMatch = RegExp(
                r'"count":\s*(\d+)',
              ).firstMatch(cleanMessage);
              if (countMatch != null) {
                data['count'] = int.parse(countMatch.group(1)!);
              }
            }
            data['message'] = 'Button clicked from WebView!';
          } else if (cleanMessage.contains('"message"')) {
            data['type'] = 'message';
            data['content'] = 'Hello from WebView!';
          } else if (cleanMessage.contains('"ready"')) {
            data['type'] = 'ready';
          }
        }
        return data;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter WebView Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              webViewController.reload();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Flutter UI Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Text(
                  '3D GLB Viewer - Flutter Side',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('Object selections: $buttonClickCount'),
                const SizedBox(height: 8),
                Text('Last selection: $webViewMessage'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _sendMessageToWebView();
                      },
                      child: const Text('Send to WebView'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _resetCounter();
                      },
                      child: const Text('Reset Counter'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // WebView Section
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: WebViewWidget(controller: webViewController),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showWebViewInfo();
        },
        tooltip: 'WebView Info',
        child: const Icon(Icons.info),
      ),
    );
  }

  void _sendMessageToWebView() {
    final message = {
      'type': 'fromFlutter',
      'content': 'Hello from Flutter!',
      'timestamp': DateTime.now().toIso8601String(),
    };

    webViewController.runJavaScript('''
      if (window.receiveMessageFromFlutter) {
        window.receiveMessageFromFlutter(${message.toString()});
      } else {
        console.log('Message from Flutter:', ${message.toString()});
      }
    ''');

    setState(() {
      webViewMessage = 'Sent message to WebView';
    });
  }

  void _resetCounter() {
    webViewController.runJavaScript('''
      if (typeof resetCounter === 'function') {
        resetCounter();
      } else {
        console.log('Reset counter function not found');
      }
    ''');

    setState(() {
      buttonClickCount = 0;
      webViewMessage = 'Counter reset';
    });
  }

  void _showWebViewInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('WebView Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Button Clicks: $buttonClickCount'),
              const SizedBox(height: 8),
              Text('Last Message: $webViewMessage'),
              const SizedBox(height: 16),
              const Text('Features:'),
              const Text('• Two-way communication between Flutter and WebView'),
              const Text('• Button click tracking'),
              const Text('• Message passing'),
              const Text('• Counter reset functionality'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
