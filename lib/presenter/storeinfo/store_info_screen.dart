import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:orre_web/services/debug.services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_web/services/debug.services.dart';
import 'package:orre_web/presenter/storeinfo/menu/store_info_screen_menu_category_list_widget.dart';
import 'package:orre_web/provider/network/https/get_service_log_state_notifier.dart';
import 'package:orre_web/provider/network/websocket/stomp_client_state_notifier.dart';
import 'package:orre_web/provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import 'package:orre_web/widget/loading_indicator/coustom_loading_indicator.dart';
import 'package:orre_web/widget/popup/alert_popup_widget.dart';
import 'package:orre_web/widget/text/text_widget.dart';

import '../../../model/store_info_model.dart';
import '../../../provider/network/websocket/store_detail_info_state_notifier.dart';
import '../../../provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import 'package:orre_web/presenter/storeinfo/store_info_screen_waiting_status.dart';
import 'google_map_button_widget.dart';
import 'store_call_button_widget.dart';
import 'store_info_screen_button_selector.dart';

class StoreDetailInfoWidget extends ConsumerStatefulWidget {
  final int storeCode;
  final String? userPhoneNumber;

  StoreDetailInfoWidget(
    this.userPhoneNumber, {
    Key? key,
    required this.storeCode,
  }) : super(key: key);

  @override
  _StoreDetailInfoWidgetState createState() => _StoreDetailInfoWidgetState();
}

class _StoreDetailInfoWidgetState extends ConsumerState<StoreDetailInfoWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stompClientStateNotifierProvider.notifier).configureClient();
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
        ref.refresh(storeDetailInfoProvider.notifier).clearStoreDetailInfo();
        break;
      case AppLifecycleState.resumed:
        if (kDebugMode) print('App is in foreground');

        ref
            .refresh(storeDetailInfoProvider.notifier)
            .reSubscribeStoreDetailInfo();
        break;
      case AppLifecycleState.detached:
        if (kDebugMode) print('App is detached');
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }

  @override
  Widget build(BuildContext context) {
    final stomp = ref.watch(stompClientStateNotifierProvider);
    final stompStatus = ref.watch(stompState);

    if (stomp == null) {
      if (kDebugMode) print("stomp null: $stomp");
    } else {
      if (kDebugMode) print("stomp not null: $stomp");

      if (stompStatus == StompStatus.DISCONNECTED) {
        if (kDebugMode) print("stomp is not activated");
      } else if (stomp.isActive) {
        ref.read(storeDetailInfoProvider.notifier).setClient(stomp);
        ref.read(storeWaitingRequestNotifierProvider.notifier).setClient(stomp);
        ref
            .read(storeWaitingUserCallNotifierProvider.notifier)
            .setClient(stomp);
        if (kDebugMode) print("stomp 변경");
        if (kDebugMode) print("stomp is activated?: ${stomp.isActive}");
        if (kDebugMode) print("stomp is connected?: ${stomp.connected}");
        if (ref.read(storeDetailInfoProvider.notifier).isClientConnected()) {
          if (kDebugMode) print("stomp is connected");
          return StreamBuilder(
              stream: ref
                  .watch(storeDetailInfoProvider.notifier)
                  .subscribeStoreDetailInfo(widget.storeCode),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (kDebugMode) print("snapshot.data has data");
                  final storeDetailInfo = snapshot.data as StoreDetailInfo?;
                  if (storeDetailInfo == null) {
                    if (kDebugMode) print("storeCode: ${widget.storeCode}");
                    return Scaffold(
                      body: Center(child: CustomLoadingIndicator()),
                    );
                  } else {
                    if (kDebugMode)
                      printd("storeDetailInfo not null: $storeDetailInfo");
                    if (widget.userPhoneNumber != null) {
                      if (kDebugMode) print("userPhoneNumber is not null");
                      return FutureBuilder(
                        future: ref
                            .watch(serviceLogProvider.notifier)
                            .fetchStoreServiceLog(widget.userPhoneNumber!),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            if (kDebugMode) print("snapshot.data is not null");

                            final userLog = snapshot.data!.userLogs;
                            if (userLog.isEmpty) {
                              // 서비스 이용 기록 없음
                              if (kDebugMode) print("userLog is empty");
                              return buildScaffold(
                                  context, storeDetailInfo, null);
                            } else {
                              // 서비스 이용 기록 있음
                              // 마지막 서비스 이용 기록 확인
                              if (kDebugMode) print("userLog is not empty");
                              if (kDebugMode)
                                printd(
                                    "last userLog: ${userLog.last.status.toKr()}");
                              return buildScaffold(
                                  context, storeDetailInfo, userLog.last);
                            }
                          } else {
                            if (kDebugMode) print("snapshot.data is null");
                            return Scaffold(
                              body: Center(child: CustomLoadingIndicator()),
                            );
                          }
                        },
                      );
                    } else {
                      if (kDebugMode) print("userPhoneNumber is null");
                      return buildScaffold(context, storeDetailInfo, null);
                    }
                  }
                } else {
                  if (kDebugMode) print("snapshot.data is null");
                  ref
                      .read(storeDetailInfoProvider.notifier)
                      .sendStoreDetailInfoRequest(widget.storeCode);
                  return Scaffold(
                    body: Center(child: CustomLoadingIndicator()),
                  );
                }
              });
        } else {
          if (kDebugMode) print("stomp is not connected");
          ref.read(storeDetailInfoProvider.notifier).setClient(stomp);
        }
      }
    }
    _handleCancelState();
    _handleUserCallAlert();
    return Scaffold(
      body: Center(child: CustomLoadingIndicator()),
    );
  }

  void _handleCancelState() {
    final cancelState = ref.watch(cancelDialogStatus);
    if (cancelState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (cancelState == 1103 || cancelState == 200) {
          ref.read(storeWaitingUserCallNotifierProvider.notifier).unSubscribe();
          ref
              .read(storeWaitingRequestNotifierProvider.notifier)
              .unSubscribe(widget.storeCode);
          ref.read(cancelDialogStatus.notifier).state = null;
          showDialog(
            context: context,
            builder: (context) {
              return AlertPopupWidget(
                title: '웨이팅 취소',
                subtitle: cancelState == 1103
                    ? '웨이팅이 가게에 의해 취소되었습니다.'
                    : '웨이팅을 취소했습니다.',
                buttonText: '확인',
              );
            },
          );
        } else if (cancelState == 1102) {
          ref.read(cancelDialogStatus.notifier).state = null;
          showDialog(
            context: context,
            builder: (context) {
              return AlertPopupWidget(
                title: '웨이팅 취소 실패',
                subtitle: '가게에 문의해주세요.',
                buttonText: '확인',
              );
            },
          );
        }
      });
    }
  }

  void _handleUserCallAlert() {
    final userCallAlert = ref.watch(userCallAlertProvider);
    if (userCallAlert) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userCallAlertProvider.notifier).state = false;
        showDialog(
          context: context,
          builder: (context) {
            return AlertPopupWidget(
              title: '입장 알림',
              subtitle:
                  "제한 시간 이내에 매장에 입장해주세요!\n입장 시간이 지나면 다음 대기자에게 넘어갈 수 있습니다.",
              buttonText: '빨리 갈게요!',
            );
          },
        );
      });
    }
  }

  Widget buildScaffold(BuildContext context, StoreDetailInfo? storeDetailInfo,
      UserLogs? userLog) {
    if (storeDetailInfo == null || storeDetailInfo.storeCode == 0) {
      return Scaffold(
        body: Center(child: CustomLoadingIndicator()),
      );
    } else {
      if (kDebugMode)
        printd(
            "storeDetailInfo waitingAvailable: ${storeDetailInfo.waitingAvailable}");
      return Scaffold(
        body: Container(
          color: Colors.white,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Color(0xFFFFB74D), // 배경색 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25), // 아래쪽 모서리 둥글게
                    bottomRight: Radius.circular(25),
                  ),
                ),
                // leading: IconButton(
                //   // 왼쪽 상단 뒤로가기 아이콘
                //   icon: Icon(Icons.arrow_back, color: Colors.white),
                //   onPressed: () {
                //     Navigator.pop(context);
                //   },
                // ),
                actions: [
                  CallButtonWidget(
                    storePhoneNumber: storeDetailInfo.storePhoneNumber,
                  ),
                  GoogleMapButtonWidget(
                    storeInfo: storeDetailInfo,
                  ),
                ],
                expandedHeight: 240, // 높이 설정
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: TextWidget(
                    storeDetailInfo.storeName,
                    color: Colors.white,
                    fontSize: 32,
                    textAlign: TextAlign.center,
                  ),
                  background: Container(
                    width: 130,
                    height: 130,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFB74D), // 원모양 배경색
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image(
                        image: CachedNetworkImageProvider(
                            storeDetailInfo.storeImageMain),
                        fit: BoxFit.cover,
                        width: 130,
                        height: 130,
                      ),
                    ),
                  ),
                ),
                pinned: true, // 스크롤시 고정
                floating: true, // 스크롤 올릴 때 축소될지 여부
                snap: true, // 스크롤을 빨리 움직일 때 자동으로 확장/축소될지 여부
              ),
              WaitingStatusWidget(
                storeCode: widget.storeCode,
                locationInfo: storeDetailInfo.locationInfo,
                userLog: userLog,
              ),
              StoreMenuCategoryListWidget(storeDetailInfo: storeDetailInfo),
              PopScope(
                child: SliverToBoxAdapter(
                  child: SizedBox(
                    height: 80,
                  ),
                ),
                onPopInvoked: (didPop) {
                  if (didPop) {
                    ref
                        .read(storeDetailInfoProvider.notifier)
                        .clearStoreDetailInfo();
                  }
                },
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: storeDetailInfo != StoreDetailInfo.nullValue()
            ? SizedBox(
                child: BottomButtonSelector(
                  userLog,
                  storeDetailInfo: storeDetailInfo,
                  nowWaitable: storeDetailInfo.waitingAvailable == 0,
                ),
                width: MediaQuery.of(context).size.width * 0.95,
              )
            : null,
      );
    }
  }

  Shader _shaderCallback(Rect rect) {
    return const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Colors.black, Colors.transparent],
      stops: [0.6, 1],
    ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
  }
}
