import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_web/presenter/storeinfo/agreement_screen.dart';
import 'package:orre_web/provider/network/websocket/stomp_client_state_notifier.dart';
import 'package:orre_web/provider/network/websocket/store_detail_info_state_notifier.dart';
import 'package:orre_web/provider/network/websocket/store_waiting_info_state_notifier.dart';
import 'package:orre_web/services/debug_services.dart';
import 'package:orre_web/widget/button/small_button_widget.dart';
import 'package:orre_web/widget/popup/alert_popup_widget.dart';
import 'package:orre_web/widget/text/text_widget.dart';
import 'package:orre_web/widget/text_field/text_input_widget.dart';
import '../../../provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import '../../services/network/https_services.dart';

final waitingSuccessDialogProvider = StateProvider<bool?>((ref) => null);

final peopleNumberProvider = StateProvider<int>((ref) => 1);

final waitingFormKeyProvider = Provider((ref) => GlobalKey<FormState>());
final waitingPhoneNumberProvider = StateProvider<TextEditingController>((ref) {
  final phoneNumberController = TextEditingController();
  phoneNumberController.text = "";
  return phoneNumberController;
});

class WaitingDialog extends ConsumerWidget {
  final int storeCode;
  final bool waitingState;

  WaitingDialog({required this.storeCode, required this.waitingState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneNumberController = ref.watch(waitingPhoneNumberProvider);
    final numberOfPerson = ref.watch(peopleNumberProvider);
    final formKey = ref.watch(waitingFormKeyProvider);
    final agreement = ref.watch(agreementState);

    return AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.white,
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 이용약관 위젯
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SmallButtonWidget(
                    minSize: Size(110.w, 50.h),
                    maxSize: Size(110.w, 50.h),
                    text: '이용약관 동의  ',
                    fontSize: 16.sp,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AgreementScreen()),
                      );
                    }),
                SizedBox(width: 8.r),
                Checkbox(
                  checkColor: Colors.white,
                  activeColor: const Color(0xFFFFB74D),
                  value: agreement,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(agreementState.notifier).state = value;
                    }
                  },
                ),
              ],
            ),

            SizedBox(height: 16.h),
            // 인원 수 선택 위젯
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.remove,
                      color: const Color(0xFFFFB74D), size: 20.sp),
                  onPressed: () {
                    if (numberOfPerson > 1) {
                      ref.read(peopleNumberProvider.notifier).state--;
                    }
                  },
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
                  width: 48.sp,
                  height: 48.sp,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFFFFB74D), width: 2.r),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: AnimatedFlipCounter(
                    value: numberOfPerson,
                    suffix: "명",
                    textStyle: TextStyle(
                        fontFamily: 'Dovemayo_gothic', fontSize: 20.sp),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add,
                      color: const Color(0xFFFFB74D), size: 20.sp),
                  onPressed: () {
                    ref.read(peopleNumberProvider.notifier).state++;
                  },
                ),
              ],
            ),

            // 전화번호 입력 위젯
            TextInputWidget(
              hintText: "전화번호",
              controller: phoneNumberController,
              isObscure: false,
              type: TextInputType.phone,
              autofillHints: [AutofillHints.telephoneNumber],
              inputFormatters: [PhoneInputFormatter()],
              minLength: 11,
              maxLength: 11,
              ref: ref,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: TextWidget("취소", fontSize: 16.sp),
          onPressed: () {
            ref.read(agreementState.notifier).state = false;
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: TextWidget("확인", fontSize: 16.sp),
          onPressed: () {
            if (formKey.currentState!.validate() && agreement == true) {
              ref.read(agreementState.notifier).state = false;
              // 입력된 정보를 처리합니다.
              print("전화번호: ${phoneNumberController.text}");
              print("인원 수: $numberOfPerson");
              print("가게 코드: $storeCode");
              print("웨이팅 시작");
              subscribeAndShowDialog(
                      context,
                      storeCode,
                      phoneNumberController.text,
                      numberOfPerson.toString(),
                      ref)
                  .then((value) {
                Navigator.of(context).pop();
                if (value == APIResponseStatus.success ||
                    value == APIResponseStatus.waitingAlreadyJoin) {
                  context.go(
                      '/reservation/$storeCode/${phoneNumberController.text}');
                } else {
                  // 웨이팅 참가에 실패할 때의 대화 상자
                  showDialog(
                    context: context,
                    builder: (context) => const AlertPopupWidget(
                      title: '웨이팅 실패',
                      subtitle: '잠시 후에 다시 시도해 주세요.',
                      buttonText: '확인',
                    ),
                  );
                }
              });
            } else {
              // 이용약관 동의 여부 확인
              if (agreement == false) {
                showDialog(
                  context: context,
                  builder: (context) => const AlertPopupWidget(
                    title: '이용약관 동의',
                    subtitle: '이용약관에 동의해 주세요.',
                    buttonText: '확인',
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Future<APIResponseStatus> subscribeAndShowDialog(
      BuildContext context,
      int storeCode,
      String phoneNumber,
      String numberOfPersons,
      WidgetRef ref) async {
    // 스트림 구독
    print("subscribeAndShowDialog");

    final waitingResult = await ref
        .read(storeWaitingRequestNotifierProvider.notifier)
        .subscribeToStoreWaitingRequest(
            storeCode, phoneNumber, int.parse(numberOfPersons));

    printd("웨이팅 성공 여부: $waitingResult");
    // 웨이팅 성공 여부에 따라
    if (waitingResult == APIResponseStatus.success ||
        waitingResult == APIResponseStatus.waitingAlreadyJoin) {
      // 성공했다면 전화번호가 포함된 링크로 이동
      await Future.delayed(Duration.zero, () {
        if (waitingResult == APIResponseStatus.success) {
          ref.read(waitingSuccessDialogProvider.notifier).state = true;
        } else {
          ref.read(waitingSuccessDialogProvider.notifier).state = false;
        }
        ref.read(streamActiveProvider.notifier).state = false;
        ref.read(storeDetailInfoProvider.notifier).clearStoreDetailInfo();
        ref.read(storeWaitingInfoNotifierProvider.notifier).clearWaitingInfo();
      });
    }

    return waitingResult;
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  static const kPhoneNumberPrefix = '010';

  // 텍스트 편집 업데이트를 처리하기 위해 formatEditUpdate 메서드를 재정의
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String formattedText = _getFormattedPhoneNumber(newValue.text);

    // 업데이트된 선택과 함께 포맷된 텍스트를 반환
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  // 전화번호의 길이에 따라 형식을 지정하는 메서드
  String _getFormattedPhoneNumber(String value) {
    value = _cleanPhoneNumber(value);

    //값이 없을 때 010최초값 포멧
    if (value.length == 1) {
      value = kPhoneNumberPrefix + value.substring(0, value.length);
    }
    // 010 을 지우지 못하도록 010 유지
    else if (value.length < 3) {
      value = kPhoneNumberPrefix;
    } else if (value.length > 11) {
      if (value.startsWith("8210")) {
        value = kPhoneNumberPrefix + value.substring(4, 12);
      } else {}
    }
    // 010xxxxxxxx 포멧
    else if (value.length >= 8 && value.length < 12) {
      value =
          '$kPhoneNumberPrefix${value.substring(3, 7)}${value.substring(7, value.length)}';
    } else {
      // 010xxxx 포멧 (자릿수 제한은 inputformatters 로 구현)
      value = kPhoneNumberPrefix + value.substring(3, value.length);
    }

    return value;
  }

  // 입력에서 숫자가 아닌 문자를 제거하는 메서드
  String _cleanPhoneNumber(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
