import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context,
    {String? title = null, required String message}) async {
  showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title ?? 'Error'),
          content: Text(message),
        );
      });
}
