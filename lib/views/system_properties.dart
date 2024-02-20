import 'package:anatomy/logics.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:anatomy/providers/providers.dart';

import '../components/markdown/markdown_ex.dart';

extension StringFirstSplit on String {
  (String, String) splitFirst(String separator) {
    int pos = indexOf(separator);

    assert(pos != -1, '$separator not found in $this');

    return pos == -1 ? (this, ''): (substring(0, pos), substring(pos + separator.length));
  }
}

String unwrap(String s) {
  return s.trim().substring(1).substring(0, s.length -2);
}

String props2table(String props) {
  return '''
| key | value |
|---|---|
''' + props.split('\n').toList().map((prop) {
    final (k, v) = prop.splitFirst(': ');

    return '| ${unwrap(k)} | $v |';
  }).join('\n');
}


class SystemPropertiesView extends HookConsumerWidget {
  const SystemPropertiesView({Key? key}) : super(key: key);

  static const tableMode = false;

  Widget _build(String value) {
    return MarkdownEx(data: '''
## System Properties

**Notice**

When sharing data, only read-only properties are shared.  
This is to avoid unintentionally sharing sensitive information.

`All properties` section follows `Read-only properties` section.

### Read-only properties

```
${tableMode ? props2table(filterReadOnly(value)) : filterReadOnly(value)}
```

### All properties

```
${tableMode ? props2table(value) : value}
```

        ''');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(systemPropertiesProvider).when(
          error: (error, stackTrace) =>
              Center(child: Text('$error\n$stackTrace')),
          loading: () => const CircularProgressIndicator(),
          data: (value) {
            return _build(value);
          },
        );
  }
}
