import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:orre_web/widget/text/text_widget.dart';

class CustomLoadingIndicator extends StatelessWidget {
  const CustomLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
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
          )
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
