import 'package:flutter/material.dart';
import 'package:orre_web/services/debug.services.dart';

class CustomLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/loading_orre.gif', // 이미지의 경로 지정
        width: MediaQuery.of(context).size.width / 2, // 이미지의 가로 크기
        height: MediaQuery.of(context).size.width / 2, // 이미지의 세로 크기
      ),
    );
  }
}
