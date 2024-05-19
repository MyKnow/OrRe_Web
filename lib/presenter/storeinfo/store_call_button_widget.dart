import 'package:flutter/material.dart';
import 'package:orre_web/services/debug.services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_platform/universal_platform.dart';

class CallButtonWidget extends StatelessWidget {
  final String storePhoneNumber;

  const CallButtonWidget({required this.storePhoneNumber});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.phone, color: Colors.white),
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
          final status = await Permission.phone.request();
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
                builder: (context) => PermissionRequestPhoneScreen(),
              ),
            );
          }
        }
      },
    );
  }
}

class PermissionRequestPhoneScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permission Request'),
      ),
      body: Center(
        child: Text('Please grant phone permission to call the store.'),
      ),
    );
  }
}
