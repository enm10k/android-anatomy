import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showShareCompleteDialog(
    BuildContext context, String deviceId) async {
  await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Complete'),
          content: Linkify(
            onOpen: (link) async => await launchUrl(Uri.parse(link.url)),
            text: 'Thanks for your contribution.\n\n'
                'The data was uploaded to https://android-anatomy.pages.dev/d/${deviceId}',
          ),
        );
      });
}
