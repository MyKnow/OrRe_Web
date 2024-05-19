import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:orre_web/services/debug.services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_web/services/debug.services.dart';
import 'package:orre_web/model/location_model.dart';
import 'package:orre_web/model/store_waiting_info_model.dart';
import 'package:orre_web/model/store_waiting_request_model.dart';
import 'package:orre_web/provider/location/now_location_provider.dart';
import 'package:orre_web/provider/network/https/get_service_log_state_notifier.dart';
import 'package:orre_web/widget/loading_indicator/coustom_loading_indicator.dart';
import 'package:orre_web/widget/text/text_widget.dart';
import '../../../provider/network/websocket/store_waiting_info_list_state_notifier.dart';
import '../../../provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import '../../../provider/waiting_usercall_time_list_state_notifier.dart';
import '../../provider/network/websocket/stomp_client_state_notifier.dart';
import '../../provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import '../../provider/network/websocket/store_waiting_info_state_notifier.dart';

class WaitingStatusWidget extends ConsumerStatefulWidget {
  final int storeCode;
  final LocationInfo locationInfo;
  final UserLogs? userLog;
  const WaitingStatusWidget(
      {super.key,
      required this.storeCode,
      required this.locationInfo,
      required this.userLog});
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
      if (widget.userLog != null) {
        ref
            .read(storeWaitingRequestNotifierProvider.notifier)
            .repairStateByServiceLog(widget.userLog!);
      }
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
        if (kDebugMode) print('App is inactive');
        break;
      case AppLifecycleState.paused:
        if (kDebugMode) print('App is in background');

        // storeInfo 구독 해제
        ref
            .refresh(storeWaitingInfoNotifierProvider.notifier)
            .clearWaitingInfo();
        break;
      case AppLifecycleState.resumed:
        if (kDebugMode) print('App is in foreground');

        ref
            .refresh(storeWaitingInfoNotifierProvider.notifier)
            .sendStoreCode(widget.storeCode);
        ref
            .refresh(storeWaitingInfoNotifierProvider.notifier)
            .reconnectByState();
        break;
      case AppLifecycleState.detached:
        if (kDebugMode) print('App is detached');
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stomp = ref.watch(stompClientStateNotifierProvider);
    final stompStatus = ref.watch(stompState);
    final myWaitingInfo = ref.watch(storeWaitingRequestNotifierProvider);
    final myUserCall = ref.watch(storeWaitingUserCallNotifierProvider);
    final remainingTime = ref.watch(waitingUserCallTimeListProvider);
    final isWaiting = ref.watch(isWaitingNow);

    if (stomp == null) {
      if (kDebugMode) print("stomp null: $stomp");
    } else {
      if (kDebugMode) print("stomp not null: $stomp");

      if (stompStatus == StompStatus.DISCONNECTED) {
        if (kDebugMode) print("stomp is not activated");
      } else if (stomp.isActive) {
        ref.read(storeWaitingInfoNotifierProvider.notifier).setClient(stomp);
        ref
            .read(storeWaitingUserCallNotifierProvider.notifier)
            .setClient(stomp);
        ref.read(storeWaitingRequestNotifierProvider.notifier).setClient(stomp);
        if (kDebugMode) print("stomp 변경");
        if (kDebugMode) print("stomp is activated?: ${stomp.isActive}");
        if (kDebugMode) print("stomp is connected?: ${stomp.connected}");
        if (ref
            .read(storeWaitingInfoNotifierProvider.notifier)
            .isClientConnected()) {
          if (kDebugMode) print("stomp is connected");
          return StreamBuilder(
              stream: ref
                  .watch(storeWaitingInfoNotifierProvider.notifier)
                  .subscribeToStoreWaitingInfo(widget.storeCode),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final waitingTeamList = snapshot.data?.enteringTeamList;
                  if (kDebugMode) print("waitingTeamList: $waitingTeamList");
                  if (kDebugMode) print("myWaitingInfo: $myWaitingInfo");
                  if (kDebugMode) print("myUserCall: $myUserCall");
                  if (kDebugMode) print("remainingTime: $remainingTime");
                  if (kDebugMode) print("isWaiting: $isWaiting");
                  return SliverToBoxAdapter(
                    child: (myWaitingInfo != null)
                        ? buildMyWaitingStatus(myWaitingInfo, snapshot.data!,
                            myUserCall, remainingTime)
                        : buildGeneralWaitingStatus(snapshot.data!, ref),
                  );
                } else {
                  ref
                      .read(storeWaitingInfoNotifierProvider.notifier)
                      .sendStoreCode(widget.storeCode);
                  return const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
              });
        }
      }
    }
    return const SliverToBoxAdapter(
      child: SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget buildMyWaitingStatus(
      StoreWaitingRequest myWaitingInfo,
      StoreWaitingInfo storeWaitingInfo,
      UserCall? myUserCall,
      Duration? remainingTime) {
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
    if (kDebugMode) print("myUserCall in buildMyWaitingStatus: $myUserCall");
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
    String distance;
    return StreamBuilder(
        stream: ref.watch(nowLocationProvider.notifier).watchNowLocation(),
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
                  const Expanded(flex: 1, child: Icon(Icons.person)),
                  const Expanded(
                      flex: 3,
                      child: TextWidget(
                        '현재 대기 팀 수',
                        textAlign: TextAlign.start,
                      )),
                  Expanded(
                    flex: 3,
                    child: TextWidget(
                      ':  ${storeWaitingInfo.waitingTeamList.length} 팀',
                      textAlign: TextAlign.start,
                    ),
                  )
                ],
              ),
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
                      ':  ${storeWaitingInfo.waitingTeamList.length * storeWaitingInfo.estimatedWaitingTimePerTeam} 분',
                      textAlign: TextAlign.start,
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Expanded(flex: 1, child: Icon(Icons.room)),
                  const Expanded(
                      flex: 3,
                      child: TextWidget(
                        '나와의 거리',
                        textAlign: TextAlign.start,
                      )),
                  Expanded(
                    flex: 3,
                    child: TextWidget(
                      ':  $distance',
                      textAlign: TextAlign.start,
                    ),
                  )
                ],
              ),
              const Divider(
                color: Color(0xFFDFDFDF),
                thickness: 2,
                endIndent: 10,
                indent: 10,
              ),
            ],
          );
        });
  }
}
