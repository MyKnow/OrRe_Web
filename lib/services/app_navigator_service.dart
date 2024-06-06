import 'package:flutter/material.dart';
import 'package:orre_web/model/store_info_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widget/popup/alert_popup_widget.dart';
import 'dart:html' as html;

import 'debug_services.dart';

void appNavigatorService(
    StoreDetailInfo storeDetailInfo, BuildContext context) async {
  // final String url = "orre://store/${widget.storeDetailInfo.storeCode}";
  // 안드로이드면 playstore로 이동
  // ios면 앱스토어로 이동
  final userAgent = html.window.navigator.userAgent.toLowerCase();

  final Uri urlScheme = Uri.parse(
    'orre://storeinfo/${storeDetailInfo.storeCode}',
  );

  if (userAgent.contains('android')) {
    print('Running on Android');
    final Uri url = Uri(
      scheme: "https",
      path: 'play.google.com/store/apps/details?id=com.aeioudev.orre',
    );
    // 앱이 배포되면 false로 변경
    if (true) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertPopupWidget(
              title: '알림',
              subtitle: '아직 Android는 앱이 출시되지 않았습니다.',
              onPressed: () {
                Navigator.pop(context);
              },
              buttonText: '확인',
            );
          });
      // ignore: dead_code
    } else {
      if (await canLaunchUrl(urlScheme)) {
        printd("canLaunch");
        await launchUrl(urlScheme);
      } else {
        printd("can't launch");
        await launchUrl(url);
      }
    }
  } else if (userAgent.contains('iphone') ||
      userAgent.contains('ipad') ||
      userAgent.contains('mac')) {
    print('Running on iOS');
    final Uri url = Uri(
      scheme: "https",
      path: 'apps.apple.com/kr/app/id6503636795',
    );
    printd("url: ${url.toString()}");

    // 앱이 깔려 있다면 앱으로 이동
    // 없다면 앱스토어로 이동
    if (await canLaunchUrl(urlScheme)) {
      printd("canLaunch");
      await launchUrl(urlScheme);
    } else {
      printd("can't launch");
      // await launchUrl(url);
      await launchUrl(Uri.parse('https://apps.apple.com/kr/app/id6503636795'));
    }
  } else {
    printd("Running on other");
  }
}
