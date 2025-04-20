import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MusicPlayerScreen extends StatelessWidget {
  final String title;
  final String url;

  const MusicPlayerScreen({Key? key, required this.title, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..loadRequest(Uri.parse(url))
          ..setJavaScriptMode(JavaScriptMode.unrestricted),
      ),
    );
  }
}
