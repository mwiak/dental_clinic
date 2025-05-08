import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

Future<String> getDeviceName() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return '${androidInfo.manufacturer} ${androidInfo.model}'; // e.g., "Google Pixel 6"
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.utsname.machine ?? 'iOS Device'; // e.g., "iPhone13,2"
  } else if (Platform.isWindows) {
    final windowsInfo = await deviceInfo.windowsInfo;
    return windowsInfo.computerName ?? 'Windows PC';
  } else if (Platform.isMacOS) {
    final macInfo = await deviceInfo.macOsInfo;
    return macInfo.model ?? 'Mac';
  } else if (Platform.isLinux) {
    final linuxInfo = await deviceInfo.linuxInfo;
    return linuxInfo.name ?? 'Linux Device';
  } else {
    return 'Unknown Device';
  }
}
