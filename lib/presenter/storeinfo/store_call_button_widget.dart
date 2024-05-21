import 'package:flutter/material.dart';
import 'package:orre_web/services/debug.services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_platform/universal_platform.dart';

class CallButtonWidget extends StatelessWidget {
  final String storePhoneNumber;
  final Color iconColor;

  const CallButtonWidget({
    super.key,
    required this.storePhoneNumber,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.phone, color: iconColor),
      onPressed: () async {
        if (UniversalPlatform.isWeb) {
          // 웹 환경에서는 tel: 링크를 사용하여 전화를 겁니다.
          final Uri telUri = Uri(scheme: 'tel', path: storePhoneNumber);
          if (await canLaunchUrl(telUri)) {
            await launchUrl(telUri);
          } else {
            throw 'Could not launch $telUri';
          }
        } else {
          // 모바일 환경에서는 전화 권한 요청 및 전화 걸기
          await Permission.phone.request().then((status) async {
            printd("status: $status");
            if (status.isGranted || UniversalPlatform.isIOS) {
              printd('Permission granted');
              printd('Call the store: $storePhoneNumber');
              await FlutterPhoneDirectCaller.callNumber(storePhoneNumber);
            } else {
              printd('Permission denied');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PermissionRequestPhoneScreen(),
                ),
              );
            }
          });
        }
      },
    );
  }
}

class PermissionRequestPhoneScreen extends StatelessWidget {
  const PermissionRequestPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Request'),
      ),
      body: const Center(
        child: Text('Please grant phone permission to call the store.'),
      ),
    );
  }
}
