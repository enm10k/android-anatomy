
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info/package_info.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../native/api.g.dart';
import '../proto/schema.pb.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
PigeonHostApi pigeonHostApi(PigeonHostApiRef ref) => PigeonHostApi();

@Riverpod(keepAlive: true)
Future<AndroidOsBuild> androidOsBuild(AndroidOsBuildRef ref) async {
  final api = ref.watch(pigeonHostApiProvider);
  final value = await api.getAndroidBuildData();
  return AndroidOsBuild.fromBuffer(value);
}

@Riverpod(keepAlive: true)
Future<AndroidOsBuildVersion> androidOsBuildVersion(
    AndroidOsBuildVersionRef ref) async {
  final api = ref.watch(pigeonHostApiProvider);
  final value = await api.getAndroidBuildVersion();
  // return AndroidOsBuildVersion.create()..mergeFromProto3Json(jsonDecode(value));
  return AndroidOsBuildVersion.fromBuffer(value);
}

@Riverpod(keepAlive: true)
Future<AndroidContentPmPackageManager> androidPackageManager(
    AndroidPackageManagerRef ref) async {
  final api = ref.watch(pigeonHostApiProvider);
  final value = await api.getAndroidPackageManager();
  return AndroidContentPmPackageManager.fromBuffer(value);
}

@Riverpod(keepAlive: true)
Future<RtcData> rtcData(RtcDataRef ref) async {
  final api = ref.watch(pigeonHostApiProvider);
  final value = await api.getWebrtcData();
  return RtcData.fromBuffer(value);
}

@Riverpod(keepAlive: true)
Future<String> cpuInfo(CpuInfoRef ref) async {
  final api = ref.watch(pigeonHostApiProvider);
  return api.getCpuInfo();
}

@Riverpod(keepAlive: true)
Future<String> systemProperties(SystemPropertiesRef ref) async {
  final api = ref.watch(pigeonHostApiProvider);
  return api.getSystemProperties();
}

@Riverpod(keepAlive: true)
PocketBase pocketBase(PocketBaseRef ref) {
  final apiUrl = dotenv.env['API_URL']!;
  debugPrint('API_URL: $apiUrl');

  // TODO: Set timeout.
  return PocketBase(apiUrl);
}

@Riverpod(keepAlive: true)
Future<String> appVersion(AppVersionRef ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPrefs(SharedPrefsRef ref) async {
  debugPrint('Loading SharedPreferences ...');
  final prefs = await SharedPreferences.getInstance();
  debugPrint('finished loading SharedPreferences.');
  return prefs;
}

const prefsKeyUuid = 'PREFS_KEY_UUID';

@Riverpod(keepAlive: true)
Future<String> uniqueId(UniqueIdRef ref) async {
  final prefs = await ref.watch(sharedPrefsProvider.future);
  final value = prefs.getString(prefsKeyUuid);

  if (value != null) {
    debugPrint('Found UUID from Prefs: $value');
    return value;
  }

  debugPrint('Generating new UUID');

  final api = ref.watch(pigeonHostApiProvider);
  final uniqueId = await api.getUniqueId();

  prefs.setString(prefsKeyUuid, uniqueId);
  debugPrint('Generated UUID: $uniqueId');
  return uniqueId;
}
