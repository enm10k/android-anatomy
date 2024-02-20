import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showShareStartDialog(BuildContext context, WidgetRef ref,
    void Function(BuildContext context, WidgetRef ref) onContinue) async {
  await showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Sign-in and Share'),
        content: Linkify(
            onOpen: (link) async => await launchUrl(Uri.parse(link.url)),
            text:
                '''Please press the "Continue" button and sign in with GitHub account.
Once you successfully sign in, your device information will be shared with https://android-anatomy.pages.dev.

Your account information like GitHub username will not be published on the site.
You can check the detail of data being shared and how it will be handled at https://github.com/enm10k/android-anatomy/.'''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abort'),
          ),
          TextButton(
            child: Text(
              'Continue',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onPressed: () => onContinue(context, ref),
          ),
        ],
      );
    },
  );
}
