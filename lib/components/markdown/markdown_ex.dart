import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownEx extends StatelessWidget {
  final String data;

  MarkdownEx({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Markdown(builders: {
      // I modified 'pre' to break lines when text overflows, but it didn't look good.
      // 'pre': MarkdownPreBuilder(),
    },data: this.data);
  }

}