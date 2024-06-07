import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_web/model/store_info_model.dart';
import 'package:orre_web/presenter/storeinfo/store_info_screen.dart';
import 'package:orre_web/presenter/storeinfo/store_info_screen_waiting_button.dart';
import 'package:orre_web/provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import 'package:orre_web/widget/popup/alert_popup_widget.dart';
import 'package:orre_web/widget/text/text_widget.dart';

class BottomButtonSelector extends ConsumerWidget {
  final StoreDetailInfo storeDetailInfo;
  final bool nowWaitable;

  const BottomButtonSelector({
    super.key,
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
      return nowWaitable
          ? WaitingButton(storeCode: storeCode, waitingState: false)
          : _buildDisabledButton(context, "현재 가게가 예약이 불가능한 상태 입니다.");
    } else if (myWaitingInfo.token.storeCode == storeCode) {
      return WaitingButton(storeCode: storeCode, waitingState: true);
    } else {
      return _buildDisabledButton(context, "현재 다른 매장에서 웨이팅 중 입니다.", storeCode,
          myWaitingInfo.token.storeCode);
    }
  }

  Widget _buildDisabledButton(BuildContext context, String message,
      [int? currentStoreCode, int? waitingStoreCode]) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 70,
      decoration: const BoxDecoration(color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
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
                  subtitle: message,
                  onPressed: waitingStoreCode != null
                      ? () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => StoreDetailInfoWidget(
                                null,
                                storeCode: waitingStoreCode,
                              ),
                            ),
                          );
                        }
                      : null,
                  buttonText: waitingStoreCode != null ? '해당 매장으로 이동' : '확인',
                );
              },
            );
          },
          label: const TextWidget('예약 불가'),
        ),
      ),
    );
  }
}
