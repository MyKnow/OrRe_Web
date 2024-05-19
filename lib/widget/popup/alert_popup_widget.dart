import 'package:flutter/material.dart';
import 'package:orre_web/widget/button/small_button_widget.dart';
import 'package:orre_web/widget/text/text_widget.dart';

class AlertPopupWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String buttonText;
  final Function()? onPressed;
  final bool autoPop;
  final bool cancelButton;
  final String cancelButtonText;

  const AlertPopupWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.buttonText,
    this.onPressed,
    this.autoPop = true,
    this.cancelButton = false,
    this.cancelButtonText = '취소',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      title: TextWidget(
        title,
        textAlign: TextAlign.center,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 66, 49, 21),
      ),
      content: (subtitle != null)
          ? TextWidget(
              subtitle!,
              textAlign: TextAlign.center,
              softWrap: true,
              fontSize: 20,
              color: const Color.fromARGB(255, 66, 49, 21),
            )
          : null,
      actions: <Widget>[
        if (cancelButton)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(
                bottom: 8), // 버튼을 AlertDialog의 가로 길이에 맞추기 위해
            child: SmallButtonWidget(
              minSize: const Size(double.infinity, 50),
              text: cancelButtonText,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        SizedBox(
          width: double.infinity, // 버튼을 AlertDialog의 가로 길이에 맞추기 위해
          child: SmallButtonWidget(
            minSize: const Size(double.infinity, 50),
            text: buttonText,
            onPressed: () {
              if (onPressed != null) {
                onPressed!();
              }
              if (autoPop) Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}
