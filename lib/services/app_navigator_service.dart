import 'package:flutter/material.dart';
import 'package:orre_web/model/store_info_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widget/popup/alert_popup_widget.dart';
import 'dart:html' as html;

import 'debug_services.dart';

void appNavigatorService(StoreDetailInfo storeDetailInfo, BuildContext context,
    bool gotoStore) async {
  final userAgent = html.window.navigator.userAgent.toLowerCase();

  final String urlScheme = 'orre://storeinfo/${storeDetailInfo.storeCode}';
  final Uri urlSchemeUri = Uri.parse(urlScheme);

  Uri? playStoreUri = Uri(
    scheme: "https",
    path: 'play.google.com/store/apps/details?id=com.aeioudev.orre',
  );
  Uri? appStoreUri = Uri.parse('https://apps.apple.com/kr/app/id6503636795');

  if (gotoStore == false) {
    playStoreUri = null;
    appStoreUri = null;
  }

  printd("userAgent: $userAgent");
  if (userAgent.contains('android')) {
    print('Running on Android');

    // TODO : 앱이 배포되면 false로 변경
    if (true) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertPopupWidget(
              title: '베타 테스터 모집 중',
              multiLineText: 'Android는 앱의 베타 테스터를 모집 중!\n지금 바로 참여하세요!',
              onPressed: () async {
                final notion = Uri.parse(
                    "https://aeioudev.notion.site/fda6350af47b42dba7e55ae65e618c10?pvs=4");
                if (await canLaunchUrl(notion)) {
                  await launchUrl(notion);
                }
              },
              buttonText: '구경하기',
              cancelButton: true,
              cancelButtonText: "취소",
            );
          });
      // ignore: dead_code
    } else {
      await launchApp(urlSchemeUri, playStoreUri);
    }
  } else if (userAgent.contains('iphone') ||
      userAgent.contains('ipad') ||
      userAgent.contains('mac os')) {
    print('Running on iOS');

    await launchApp(urlSchemeUri, appStoreUri);
  } else {
    printd("Running on other");
    if (gotoStore) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertPopupWidget(
            title: '플랫폼 미지원',
            subtitle: '현재 오리는 Android와 iOS만 지원하고 있습니다.',
            onPressed: () async {},
            buttonText: '확인',
          );
        },
      );
    }
  }
}

Future<void> launchApp(Uri urlSchemeUri, Uri? storeUri) async {
  await launchUrl(urlSchemeUri);
  if (storeUri != null) {
    Future.delayed(
      const Duration(seconds: 2),
      () async {
        if (!await canLaunchUrl(urlSchemeUri)) {
          await launchUrl(
            storeUri,
          );
        }
      },
    );
  }
}
