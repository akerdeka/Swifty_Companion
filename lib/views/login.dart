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
  bool _isLoading = true;
  bool _isSpin = false;
  String? client_secret = dotenv.env['secret_id'];
  String? client_id = dotenv.env['client_id'];

  @override
  Widget build(BuildContext context) {
    final _webViewController = WebViewController()
    ..clearCache()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
          },
          onPageFinished: (String url) {

          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('swifty://')) {
              if (context.mounted) {
                setState(() {
                  _isLoading = false;
                  _isSpin = true;
                });
              }

              var uri = Uri.parse(request.url);
              uri.queryParameters.forEach((k, v) async {
                if (k == 'code') {
                  http.Response res = await http.post(Uri.parse(
                      'https://api.intra.42.fr/oauth/token?grant_type=authorization_code&client_id=$client_id&client_secret=$client_secret&code=$v&redirect_uri=swifty%3A%2F%2F10.13.4.6%2F'));
                  if (res.statusCode == 200) {
                    widget.storage.write(
                        key: 'token',
                        value: jsonDecode(res.body)["access_token"]);
                    widget.storage.write(
                        key: 'refresh_token',
                        value: jsonDecode(res.body)["refresh_token"]);
                    widget.storage.write(
                        key: 'expires_in',
                        value: jsonDecode(res.body)["expires_in"].toString());
                    if (context.mounted) {
                      widget.onLoginChanged(true);
                    }
                  }
                }
              });
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://api.intra.42.fr/oauth/authorize?client_id=$client_id&redirect_uri=swifty%3A%2F%2F10.13.4.6%2F&response_type=code'));

    _webViewController.clearCache();
    _webViewController.clearLocalStorage();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: _isLoading ? WebViewWidget(controller: _webViewController) : _isSpin ? const Center(child: CircularProgressIndicator(),) : const SizedBox(),
    );
  }
}
