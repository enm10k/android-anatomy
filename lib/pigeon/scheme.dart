import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/native/api.g.dart',
  dartOptions: DartOptions(),
  kotlinOut: 'android/app/src/main/kotlin/com/enm10k/anatomy/Pigeon.g.kt',
  kotlinOptions: KotlinOptions(),
  dartPackageName: 'anatomy',
))
@HostApi()
abstract class PigeonHostApi {
  Uint8List getAndroidBuildData();
  Uint8List getAndroidBuildVersion();
  Uint8List getAndroidPackageManager();
  String getCpuInfo();
  String getSystemProperties();

  String getUniqueId();

  @async
  Uint8List getWebrtcData();
}

@FlutterApi()
abstract class MessageFlutterApi {
  String flutterMethod(String? aString);
}
