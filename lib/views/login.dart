import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.onLoginChanged, required this.storage});

  final ValueChanged<bool> onLoginChanged;
  final storage;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  String? client_secret = dotenv.env['secret_id'];
  String? client_id = dotenv.env['client_id'];

  @override
  Widget build(BuildContext context) {
    final _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {

            var uri = Uri.parse(url);
            uri.queryParameters.forEach((k, v) async {
              if (k == 'code') {
                http.Response res = await http.post(
                    Uri.parse('https://api.intra.42.fr/oauth/token?grant_type=authorization_code&client_id=$client_id&client_secret=$client_secret&code=$v&redirect_uri=http%3A%2F%2F10.13.4.6%2F'));
                if (res.statusCode == 200) {
                  widget.onLoginChanged(true);
                  widget.storage.write(key: 'token', value: jsonDecode(res.body)["access_token"]);
                  widget.storage.write(key: 'refresh_token', value: jsonDecode(res.body)["refresh_token"]);
                  widget.storage.write(key: 'expires_in', value: jsonDecode(res.body)["expires_in"].toString());
                }
              }
            });
          },
          onWebResourceError: (WebResourceError error) {
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://api.intra.42.fr/oauth/authorize?client_id=$client_id&redirect_uri=http%3A%2F%2F10.13.4.6%2F&response_type=code'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: WebViewWidget(controller: _webViewController),
    );
  }
}
