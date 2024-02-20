import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownPreBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) {
    Size screenSize = WidgetsBinding.instance.window.physicalSize;
    return Container(child: Text(
        text.text,
        softWrap: true,
        style: preferredStyle
    ),
      // decoration: BoxDecoration(color: Colors.black),
      padding: MarkdownStyleSheet().codeblockPadding,
      decoration: MarkdownStyleSheet().codeblockDecoration,
      width: screenSize.width * 0.9,
    );
  }
}