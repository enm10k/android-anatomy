import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:anatomy/providers/providers.dart';

import '../proto/schema.pb.dart';

String camel2snake(String camel) {
  return camel.replaceAllMapped(RegExp(r'([0-9]+[a-z]|[A-Z])'),
      (match) => '_${match.group(1)!.toLowerCase()}');
}

String composeTable(Map<String, dynamic> data) {
  return data.entries
      .map((e) => '| ${camel2snake(e.key).toUpperCase()} | ${e.value} |')
      .toList()
      .join('\n');
}

class GeneralView extends HookConsumerWidget {
  const GeneralView({Key? key}) : super(key: key);

  Widget _build(AndroidOsBuild b, AndroidOsBuildVersion bv, String c, AndroidContentPmPackageManager pm) {
    return Markdown(data: '''
## android.os.Build

| Parameter | Value |
|---| ---|
${composeTable(b.toProto3Json() as Map<String, dynamic>)}

## android.os.Build.VERSION

| Parameter | Value |
|---|---|
${composeTable(bv.toProto3Json() as Map<String, dynamic>)}

## android.content.pm.PackageManager

### System available features

```
${(pm.systemAvailableFeatures..sort()).join('\n')}
```

### System shared libraries

```
${(pm.systemSharedLibraryNames.toList()..sort()).join('\n')}
```

## /proc/cpuinfo

```
$c
```
        ''');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w =
        useState<Widget>(const Center(child: CircularProgressIndicator()));

    AndroidOsBuild? b;
    AndroidOsBuildVersion? bv;
    String? c;
    AndroidContentPmPackageManager? pm;

    final futures = [
      ref.watch(androidOsBuildProvider.future).then((value) {
        b = value;
      }),
      ref.watch(androidOsBuildVersionProvider.future).then((value) {
        bv = value;
      }),
      ref.watch(cpuInfoProvider.future).then((value) {
        c = value;
      }),
      ref.watch(androidPackageManagerProvider.future).then((value) =>
        pm = value
      )
    ];

    // ref.watch(debugProvider).when(data: (data) => debugPrint(data), error: (e, s) => debugPrint('$e $s'), loading: () => debugPrint('loading'));

    useEffect(() {
      Future.wait(futures).then((_) async {
        debugPrint(pm!.toProto3Json().toString());
        // await Future.delayed(const Duration(seconds: 5));
        w.value = _build(b!, bv!, c!, pm!);
      }).onError((error, stackTrace) {
        w.value = Center(child: Text('$error\n$stackTrace'));
      });
      return null;
    }, []);

    return w.value;
  }
}
