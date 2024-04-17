import 'package:flutter/cupertino.dart';

class ErrorHandler extends StatefulWidget {
  const ErrorHandler({super.key, required this.errorText});

  final String errorText;

  @override
  State<ErrorHandler> createState() => _ErrorHandlerState();
}

class _ErrorHandlerState extends State<ErrorHandler> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.errorText);
  }
}
