import 'package:anatomy/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';

String filterReadOnly(String s) {
  return s
      .split('\n')
      .where((line) => line.startsWith('[ro.'))
      .toList()
      .join('\n');
}

Future<bool> signInIfNeeded(WidgetRef ref) async {
  final pb = await ref.read(pocketBaseProvider);
  debugPrint('isValid(before): ${pb.authStore.isValid}');
  if (!pb.authStore.isValid) {
    pb.authStore.clear();
    await pb.collection('users').authWithOAuth2('github', (url) async {
      await launchUrl(url);
    });
  }

  return pb.authStore.isValid;
}

Future<bool> checkAlreadyUploaded(WidgetRef ref) async {
  // Need to sign-in before calling this function.
  final pb = ref.watch(pocketBaseProvider);
  final uuid = await ref.watch(uniqueIdProvider.future);
  final userId = pb.authStore.model.id ?? '';

  debugPrint('uuid: $uuid');
  debugPrint('userId: $userId');

  final result =
      await pb.collection('my_devices').getList(filter: 'uuid="$uuid"');
  debugPrint('result: $result');
  return result.totalItems != 0;
}

Future<RecordModel> upload(WidgetRef ref, BuildContext context) async {
  final (b, bv, w, c, p, v, pm, uuid) = await (
    ref.read(androidOsBuildProvider.future),
    ref.read(androidOsBuildVersionProvider.future),
    ref.read(rtcDataProvider.future),
    ref.read(cpuInfoProvider.future),
    ref.read(systemPropertiesProvider.future),
    ref.read(appVersionProvider.future),
    ref.read(androidPackageManagerProvider.future),
    ref.read(uniqueIdProvider.future),
  ).wait;

  final pb = ref.watch(pocketBaseProvider);

  final Map<String, dynamic> body = {
    'user_id': pb.authStore.model!.id,
    'title': '${b.manufacturer} ${b.model}',
    'app_version': v,
    'fingerprint': b.fingerprint,
    'uuid': uuid,
    'android_os_build': b.toProto3Json(),
    'android_os_build_version': bv.toProto3Json(),
    'android_content_pm_package_manager': pm.toProto3Json(),
    'webrtc': w.toProto3Json(),
    'cpu_info': c,
    'system_properties': filterReadOnly(p),
    'is_public': true,
  };

  return await pb.collection('devices').create(
        body: body,
      );
}
