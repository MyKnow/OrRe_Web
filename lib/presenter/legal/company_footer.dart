// 회사 Footer 정보를 보여주는 위젯
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/app_version_service.dart';
import '../../widget/text/text_widget.dart';

class CompanyFooter extends ConsumerWidget {
  final double fontSize;
  const CompanyFooter(this.fontSize, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextWidget(
            "단모음데브 대표 정민호 | ",
            fontSize: fontSize,
            color: Colors.grey,
          ),
          TextWidget("주소 : 경기도 용인시 기흥구 보정동 1189-3, 3층 일부 | ",
              fontSize: fontSize, color: Colors.grey),
          TextWidget(
            "사업자 등록번호 865-18-02259 | ",
            fontSize: fontSize,
            color: Colors.grey,
          ),
          Consumer(
            builder: (context, ref, child) {
              // final appVersion = ref.watch(appVersionProvider);
              return TextWidget(
                "버전 : ${getAppVersion()} | ",
                fontSize: fontSize,
                color: Colors.grey,
              );
            },
          ),
          TextButton(
            onPressed: () {
              context.push('/legal/license');
            },
            style: TextButton.styleFrom(
              // 버튼의 크기를 글자 크기에 딱 맞게 설정
              minimumSize: const Size(0, 0),
              padding: EdgeInsets.zero,
            ),
            child: TextWidget(
              "라이센스",
              fontSize: fontSize,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
