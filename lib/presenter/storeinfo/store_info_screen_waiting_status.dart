import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:orre_web/services/debug.services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_web/model/location_model.dart';
import 'package:orre_web/model/store_waiting_info_model.dart';
import 'package:orre_web/model/store_waiting_request_model.dart';
import 'package:orre_web/provider/location/now_location_provider.dart';
import 'package:orre_web/widget/text/text_widget.dart';
import '../../../provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import '../../provider/network/websocket/stomp_client_state_notifier.dart';
import '../../provider/network/websocket/store_waiting_info_state_notifier.dart';

class WaitingStatusWidget extends ConsumerStatefulWidget {
  final int storeCode;
  final LocationInfo locationInfo;
  const WaitingStatusWidget({
    super.key,
    required this.storeCode,
    required this.locationInfo,
  });
  @override
  // ignore: library_private_types_in_public_api
  _WaitingStatusWidgetState createState() => _WaitingStatusWidgetState();
}

class _WaitingStatusWidgetState extends ConsumerState<WaitingStatusWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref
          .read(stompClientStateNotifierProvider.notifier)
          .connect()
          .then((value) {
        printd(
            "stompClientStateNotifierProvider connect then : ${value?.connected}");
        if (value == null) {
          ref.read(stompClientStateNotifierProvider.notifier).connect();
        } else {
          ref.read(storeWaitingInfoNotifierProvider.notifier).setClient(value);
          ref
              .read(storeWaitingInfoNotifierProvider.notifier)
              .subscribeToStoreWaitingInfo(widget.storeCode);
          ref
              .read(storeWaitingInfoNotifierProvider.notifier)
              .sendStoreCode(widget.storeCode);
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        printd('App is inactive');
        break;
      case AppLifecycleState.paused:
        printd('App is in background');

        // storeInfo 구독 해제
        ref
            .refresh(storeWaitingInfoNotifierProvider.notifier)
            .clearWaitingInfo();
        break;
      case AppLifecycleState.resumed:
        printd('App is in foreground');

        ref
            .refresh(storeWaitingInfoNotifierProvider.notifier)
            .sendStoreCode(widget.storeCode);
        ref
            .refresh(storeWaitingInfoNotifierProvider.notifier)
            .reconnectByState();
        break;
      case AppLifecycleState.detached:
        printd('App is detached');
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    printd("\nWaitingStatusWidget 진입");
    final storeWaitingInfo = ref.watch(storeWaitingInfoNotifierProvider);

    if (storeWaitingInfo == null) {
      return const SliverToBoxAdapter(
          child: Center(
        child: CircularProgressIndicator(),
      ));
    } else {
      return SliverToBoxAdapter(
        child: buildGeneralWaitingStatus(storeWaitingInfo, ref),
      );
    }
  }

  Widget buildMyWaitingStatus(
      StoreWaitingRequest myWaitingInfo,
      StoreWaitingInfo storeWaitingInfo,
      UserCall? myUserCall,
      Duration? remainingTime) {
    printd("\nbuildMyWaitingStatus 진입");
    final myWaitingNumber = myWaitingInfo.token.waiting;
    final myWaitingIndex =
        storeWaitingInfo.waitingTeamList.indexOf(myWaitingNumber);

    List<Widget> children = [
      const SizedBox(
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Expanded(flex: 1, child: Icon(Icons.person)),
          const Expanded(
              flex: 3,
              child: TextWidget(
                '남은 팀 수',
                textAlign: TextAlign.start,
              )),
          Expanded(
            flex: 3,
            child: TextWidget(
              ': $myWaitingIndex 팀',
              textAlign: TextAlign.start,
            ),
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Expanded(flex: 1, child: Icon(Icons.info_outline)),
          const Expanded(
              flex: 3,
              child: TextWidget(
                '웨이팅 번호',
                textAlign: TextAlign.start,
              )),
          Expanded(
            flex: 3,
            child: TextWidget(
              ': $myWaitingNumber 번',
              textAlign: TextAlign.start,
            ),
          )
        ],
      ),
      // TextWidget('내 웨이팅 번호: $myWaitingNumber'),
      // TextWidget("내 웨이팅 인원: ${myWaitingInfo.token.personNumber}명"),
      // TextWidget('내 웨이팅 전화번호: ${myWaitingInfo.token.phoneNumber}'),
      // TextWidget('남은 팀 수 : $myWaitingIndex'),
    ];
    printd("myUserCall in buildMyWaitingStatus: $myUserCall");
    if (myUserCall != null &&
        remainingTime != null &&
        remainingTime.inSeconds > 0) {
      children.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Expanded(
                flex: 1,
                child: Icon(
                  Icons.watch_later,
                  color: Color(0xFFFFB74D),
                )),
            const Expanded(
                flex: 3,
                child: TextWidget(
                  '남은 입장 시간',
                  textAlign: TextAlign.start,
                  color: Color(0xFFFFB74D),
                )),
            Expanded(
              flex: 3,
              child: TextWidget(
                ': ${remainingTime.inSeconds} 초',
                textAlign: TextAlign.start,
                color: const Color(0xFFFFB74D),
              ),
            )
          ],
        ),
      );
    } else {
      children.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Expanded(flex: 1, child: Icon(Icons.watch_later)),
            const Expanded(
                flex: 3,
                child: TextWidget(
                  '예상 대기 시간',
                  textAlign: TextAlign.start,
                )),
            Expanded(
              flex: 3,
              child: TextWidget(
                ': ${myWaitingIndex * storeWaitingInfo.estimatedWaitingTimePerTeam} 분',
                textAlign: TextAlign.start,
              ),
            )
          ],
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget buildGeneralWaitingStatus(
      StoreWaitingInfo storeWaitingInfo, WidgetRef ref) {
    printd("buildGeneralWaitingStatus 진입");
    String distance;
    final nowLocationStream =
        ref.watch(nowLocationProvider.notifier).watchNowLocation();
    return StreamBuilder(
        stream: nowLocationStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final nowLocation = snapshot.data;
            distance = '${nowLocation! - widget.locationInfo}m';
          } else {
            distance = '위치 정보를 불러오는 중입니다.';
          }
          return Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: Icon(Icons.person, size: 16.sp)),
                  Expanded(
                      flex: 3,
                      child: TextWidget(
                        '현재 대기 팀 수',
                        textAlign: TextAlign.start,
                        fontSize: 16.sp,
                      )),
                  Expanded(
                    flex: 6,
                    child: TextWidget(
                      ':  ${storeWaitingInfo.waitingTeamList.length} 팀',
                      textAlign: TextAlign.start,
                      fontSize: 16.sp,
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 1, child: Icon(Icons.watch_later, size: 16.sp)),
                  Expanded(
                      flex: 3,
                      child: TextWidget(
                        '예상 대기 시간',
                        textAlign: TextAlign.start,
                        fontSize: 16.sp,
                      )),
                  Expanded(
                    flex: 6,
                    child: TextWidget(
                      ':  ${storeWaitingInfo.waitingTeamList.length * storeWaitingInfo.estimatedWaitingTimePerTeam} 분',
                      textAlign: TextAlign.start,
                      fontSize: 16.sp,
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: Icon(Icons.room, size: 16.sp)),
                  Expanded(
                      flex: 3,
                      child: TextWidget(
                        '나와의 거리',
                        textAlign: TextAlign.start,
                        fontSize: 16.sp,
                      )),
                  Expanded(
                    flex: 6,
                    child: TextWidget(
                      ':  $distance',
                      textAlign: TextAlign.start,
                      fontSize: 16.sp,
                    ),
                  )
                ],
              ),
              Divider(
                color: const Color(0xFFDFDFDF),
                thickness: 2.r,
                endIndent: 10.r,
                indent: 10.r,
              ),
            ],
          );
        });
  }
}
