import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:anatomy/providers/providers.dart';

import '../components/markdown/markdown_ex.dart';
import '../proto/schema.pb.dart';

String formatFps(double fps) {
  return (fps / 1000).toStringAsFixed(1);
}

String formatCameraName(RtcCamera camera) {
  return "${camera.isBackFacing ? "Back" : "Front"} camera (${camera.name})";
}

String camera2md(RtcCamera camera) {
  return """

### ${formatCameraName(camera)}

#### supportedFormats

| size | fps | format |
|---|---|---|
${camera.imageFormats.map((e) => "| ${e.width}x${e.height} | ${formatFps(e.frameRateMin)}-${formatFps(e.frameRateMax)} | ${e.imageFormat} |").join('\n')}

""";
}

String cameras2md(List<RtcCamera?> cameras) {
  return cameras.map((e) => camera2md(e!)).join('\n');
}

final encoder = JsonEncoder.withIndent('  ');

String codec2md(RtcCodec c) {
  return '''
### ${c.name}: ${c.implementationName}

#### params

```
${encoder.convert(c.params)}
```

#### scalabilityModes

```
${encoder.convert(c.scalabilityModes)}
```

''';
}

class WebrtcView extends HookConsumerWidget {
  const WebrtcView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(rtcDataProvider).when(
          error: (error, stackTrace) =>
              Center(child: Text('$error\n$stackTrace')),
          loading: () => const CircularProgressIndicator(),
          data: (value) {
            return MarkdownEx(data: """
## Version

${value.version}

## Hardware Video Encoder

${value.hwEncoderCodecs.map((c) => codec2md(c)).join('\n')}

## Hardware Video Decoder

${value.hwDecoderCodecs.map((c) => codec2md(c)).join('\n')}

## Camera

${value.cameras.map((camera) => "- ${formatCameraName(camera)})").join('\n')}

${cameras2md(value.cameras)}
        """);
          },
        );
  }
}
