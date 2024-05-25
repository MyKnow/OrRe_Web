import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:orre_web/provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import 'package:orre_web/services/debug.services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_web/presenter/storeinfo/menu/store_info_screen_menu_category_list_widget.dart';
import 'package:orre_web/provider/network/https/get_service_log_state_notifier.dart';
import 'package:orre_web/provider/network/websocket/stomp_client_state_notifier.dart';
import 'package:orre_web/services/network/https_services.dart';
import 'package:orre_web/widget/loading_indicator/coustom_loading_indicator.dart';
import 'package:orre_web/widget/popup/alert_popup_widget.dart';
import 'package:orre_web/widget/text/text_widget.dart';

import '../../../model/store_info_model.dart';
import '../../../provider/network/websocket/store_detail_info_state_notifier.dart';
import 'package:orre_web/presenter/storeinfo/store_info_screen_waiting_status.dart';
import 'google_map_button_widget.dart';
import 'store_call_button_widget.dart';
import 'store_info_screen_button_selector.dart';

class StoreDetailInfoWidget extends ConsumerStatefulWidget {
  final int storeCode;
  final String? userPhoneNumber;

  const StoreDetailInfoWidget(
    this.userPhoneNumber, {
    super.key,
    required this.storeCode,
  });

  @override
  // ignore: library_private_types_in_public_api
  _StoreDetailInfoWidgetState createState() => _StoreDetailInfoWidgetState();
}

class _StoreDetailInfoWidgetState extends ConsumerState<StoreDetailInfoWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    printd("StoreDetailInfoWidget initState");
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(stompClientStateNotifierProvider.notifier)
          .connect()
          .then((value) {
        printd(
            "stompClientStateNotifierProvider connect then : ${value?.connected}");
        if (value == null) {
          ref.read(stompClientStateNotifierProvider.notifier).connect();
        } else {
          ref.read(storeDetailInfoProvider.notifier).setClient(value);
          ref
              .read(storeDetailInfoProvider.notifier)
              .subscribeStoreDetailInfo(widget.storeCode);
          ref
              .read(storeDetailInfoProvider.notifier)
              .sendStoreDetailInfoRequest(widget.storeCode);
        }
      });
    });
  }

  @override
  void dispose() {
    printd("StoreDetailInfoWidget dispose");
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
        ref.refresh(storeDetailInfoProvider.notifier).clearStoreDetailInfo();
        break;
      case AppLifecycleState.resumed:
        printd('App is in foreground');

        ref
            .refresh(storeDetailInfoProvider.notifier)
            .reSubscribeStoreDetailInfo();
        break;
      case AppLifecycleState.detached:
        printd('App is detached');
        break;
      case AppLifecycleState.hidden:
        printd('App is hidden');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeDetailInfo = ref.watch(storeDetailInfoProvider);
    final userLog = ref.watch(serviceLogProvider);

    if (storeDetailInfo == null) {
      return const Scaffold(
        body: Center(child: CustomLoadingIndicator()),
      );
    } else {
      return buildScaffold(
          context, storeDetailInfo, userLog.userLogs.lastOrNull);
    }
  }

  Widget buildScaffold(BuildContext context, StoreDetailInfo? storeDetailInfo,
      UserLogs? userLog) {
    printd("\nbuildScaffold 진입");
    if (storeDetailInfo == null || storeDetailInfo.storeCode == 0) {
      return const Scaffold(
        body: Center(child: CustomLoadingIndicator()),
      );
    } else {
      printd(
          "storeDetailInfo waitingAvailable: ${storeDetailInfo.waitingAvailable}");
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          color: Colors.white,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFFFFB74D), // 배경색 설정
                shape: const RoundedRectangleBorder(
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
                  titlePadding: const EdgeInsets.only(bottom: 12),
                  title: TextWidget(
                    storeDetailInfo.storeName,
                    color: Colors.white,
                    fontSize: 24,
                    textAlign: TextAlign.center,
                  ),
                  background: Container(
                    width: 130,
                    height: 130,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
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
              ),
              StoreMenuCategoryListWidget(storeDetailInfo: storeDetailInfo),
              PopScope(
                child: const SliverToBoxAdapter(
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
                width: MediaQuery.of(context).size.width * 0.95,
                child: BottomButtonSelector(
                  storeDetailInfo: storeDetailInfo,
                  nowWaitable: storeDetailInfo.waitingAvailable == 0,
                ),
              )
            : null,
      );
    }
  }
}
