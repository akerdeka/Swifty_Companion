import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TopBar extends StatefulWidget {
  const TopBar(
      {super.key, required this.onLoginChanged, required this.storage});

  final ValueChanged<bool> onLoginChanged;
  final storage;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        child: AppBar(
            backgroundColor: Colors.transparent,
            actions: <Widget>[
              IconButton(
                  onPressed: () async {
                    await widget.storage.deleteAll();
                    widget.onLoginChanged(false);
                  },
                  icon: const Icon(Icons.logout))
            ]),
      );
  }
}