import 'package:flutter/material.dart';
import 'package:orre_web/widget/text/text_widget.dart';

class CustomLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment
            .center, // Align the column in the center vertically
        children: [
          Image.asset(
            'assets/images/loading_orre.gif',
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.width / 2,
          ),
          SizedBox(
            height: 20,
          ),
          const TextWidget(
            '로딩이 너무 오래 걸릴 경우 새로고침 해주세요.',
            fontSize: 24,
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
