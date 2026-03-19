import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  WebViewController? controller;

  final Uri url = Uri.parse(
    "https://docs.google.com/spreadsheets/d/1N-8ZbnpqlKt2bsdk4UnBYCKJM6slHK2aHyKNMYaHVQA/preview",
  );

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(url);
    }
  }

  Future<void> openBrowser() async {
    await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Timetable")),

      body: kIsWeb
          ? Center(
              child: ElevatedButton(
                onPressed: openBrowser,
                child: const Text("Open Timetable"),
              ),
            )
          : controller == null
              ? const Center(child: CircularProgressIndicator())
              : WebViewWidget(controller: controller!),
    );
  }
}