import 'package:flutter_riverpod/flutter_riverpod.dart';

final appVersionProvider =
    StateNotifierProvider<AppVersionNotifier, String>((ref) {
  return AppVersionNotifier();
});

class AppVersionNotifier extends StateNotifier<String> {
  AppVersionNotifier() : super("1.0.0");

  void setAppVersion(String version) {
    state = version;
  }
}
