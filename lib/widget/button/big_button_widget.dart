import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_web/widget/text/text_widget.dart';

class BigButtonWidget extends ConsumerWidget {
  final String text;
  final double textSize;
  final Function onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Size minimumSize;
  final Size maximumSize;
  final OutlinedBorder shape;

  const BigButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFFFFB74D),
    this.textColor = Colors.black,
    this.textSize = 16,
    this.minimumSize = const Size(double.infinity, 50),
    this.maximumSize = const Size(double.infinity, 50),
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
    ),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: minimumSize,
        maximumSize: maximumSize,
        shape: shape,
      ),
      child: TextWidget(
        text,
        color: textColor,
        fontSize: textSize,
      ),
    );
  }
}
