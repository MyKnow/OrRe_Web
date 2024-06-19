import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../provider/app_state_provider.dart';
import 'debug_services.dart';

Future<void> initializePackageInfo(WidgetRef ref) async {
  try {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    ref.read(appVersionProvider.notifier).setAppVersion(packageInfo.version);
  } catch (e) {
    printd("Error fetching package info: $e");
  }
}

// TODO : 비정상 작동으로 인한 하드 코딩 버전
String getAppVersion() {
  return "1.0.5+6";
}
