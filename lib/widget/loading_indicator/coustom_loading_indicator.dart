import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:orre_web/widget/button/big_button_widget.dart';
import 'package:orre_web/widget/text/text_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomLoadingIndicator extends ConsumerWidget {
  String who = '';
  CustomLoadingIndicator({super.key, required this.who});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("CustomLoadingIndicator build who: $who");
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment
            .center, // Align the column in the center vertically
        children: [
          CustomLoadingImage(size: 200.r),
          SizedBox(
            height: 16.r,
          ),
          TextWidget(
            '로딩이 너무 오래 걸릴 경우 새로고침 해주세요.',
            fontSize: 16.r,
            color: Colors.black,
            fontFamily: 'Dovemayo_gothic',
            textAlign: TextAlign.center,
            fontWeight: FontWeight.normal,
            softWrap: false,
            padding: const EdgeInsets.all(0),
            overflow: TextOverflow.clip,
            maxLines: 1,
          ),
          SizedBox(
            height: 16.r,
          ),
          // TextWidget(
          //   '호출 : $who',
          //   fontSize: 16.r,
          //   color: Colors.black,
          //   fontFamily: 'Dovemayo_gothic',
          //   textAlign: TextAlign.center,
          //   fontWeight: FontWeight.normal,
          //   softWrap: false,
          //   padding: const EdgeInsets.all(0),
          //   overflow: TextOverflow.clip,
          //   maxLines: 1,
          // ),
          SizedBox(
            height: 16.r,
          ),
          BigButtonWidget(
            text: "새로고침하기",
            onPressed: () async {
              // 현재 주소를 그대로 URL 런처로 열어서 새로고침
              // ignore: unawaited_futures
              final uri = Uri.base; // 현재 URL 가져오기
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri,
                    mode: LaunchMode.inAppBrowserView); // 새로운 브라우저 창 열기
              } else {
                throw 'Could not launch $uri';
              }
            },
          ),
        ],
      ),
    );
  }
}

class CustomLoadingImage extends StatelessWidget {
  final double size;
  const CustomLoadingImage({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment
            .center, // Align the column in the center vertically
        children: [
          Image.asset(
            'assets/images/loading_orre.gif',
            width: size,
            height: size,
          ),
        ],
      ),
    );
  }
}
