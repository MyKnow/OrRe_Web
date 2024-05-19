import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_web/presenter/storeinfo/store_info_screen.dart';
import 'package:orre_web/presenter/storeinfo/store_info_screen_waiting_button.dart';
import 'package:orre_web/provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import 'package:orre_web/widget/popup/alert_popup_widget.dart';
import 'package:orre_web/widget/text/text_widget.dart';
import '../../../provider/network/https/store_detail_info_state_notifier.dart';
import '../../model/store_info_model.dart';
import '../../provider/network/https/get_service_log_state_notifier.dart';

class BottomButtonSelector extends ConsumerWidget {
  final StoreDetailInfo storeDetailInfo;
  final bool nowWaitable;
  final UserLogs? userLog;
  const BottomButtonSelector(
    this.userLog, {
    required this.storeDetailInfo,
    required this.nowWaitable,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeCode = storeDetailInfo.storeCode;
    final myWaitingInfo = ref.watch(storeWaitingRequestNotifierProvider);
    print(
        "BottomButtonSelector build!!!!!!!!!!!!!!!!! ${storeDetailInfo.waitingAvailable} : $nowWaitable ");

    if (myWaitingInfo == null) {
      print("myWaitingInfo is null");
      // 현재 웨이팅 중이 아님
      if (nowWaitable) {
        return WaitingButton(storeCode: storeCode, waitingState: false);
      } else {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 70,
          decoration: BoxDecoration(color: Colors.white),
          child: Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertPopupWidget(
                          title: "웨이팅 불가",
                          subtitle: "현재 가게가 예약이 불가능한 상태 입니다.",
                          buttonText: '확인',
                        );
                      },
                    );
                  },
                  label: TextWidget('예약 불가'))),
        );
      }
    } else {
      // 현재 웨이팅 중임
      print("myWaitingInfo is not null : ${myWaitingInfo.token.storeCode}");
      print("storeCode : $storeCode");
      if (myWaitingInfo.token.storeCode == storeCode) {
        // 현재 웨이팅 중인 가게임
        print("myWaitingInfo: $myWaitingInfo");
        return WaitingButton(storeCode: storeCode, waitingState: true);
      } else {
        // 다른 가게에서 웨이팅 중임
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 70,
          decoration: BoxDecoration(color: Colors.white),
          child: Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertPopupWidget(
                          title: "웨이팅 불가",
                          subtitle: "현재 다른 매장에서 웨이팅 중 입니다.",
                          autoPop: false,
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => StoreDetailInfoWidget(
                                  null,
                                  storeCode: myWaitingInfo.token.storeCode,
                                ),
                              ),
                            );
                          },
                          buttonText: '해당 매장으로 이동',
                        );
                      },
                    );
                  },
                  label: TextWidget('중복 예약 불가'))),
        );
      }
    }
  }
}
