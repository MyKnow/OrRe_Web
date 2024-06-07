import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:orre_web/provider/app_state_provider.dart';
import 'package:orre_web/provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import 'package:orre_web/services/app_navigator_service.dart';
import 'package:orre_web/services/debug_services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_web/presenter/storeinfo/menu/store_info_screen_menu_category_list_widget.dart';
import 'package:orre_web/provider/network/websocket/stomp_client_state_notifier.dart';
import 'package:orre_web/widget/button/small_button_widget.dart';
import 'package:orre_web/widget/loading_indicator/coustom_loading_indicator.dart';
import 'package:orre_web/widget/text/text_widget.dart';

import '../../../model/store_info_model.dart';
import '../../../provider/network/websocket/store_detail_info_state_notifier.dart';
import 'package:orre_web/presenter/storeinfo/store_info_screen_waiting_status.dart';
import '../../services/app_version_service.dart';
import 'google_map_button_widget.dart';
import 'store_call_button_widget.dart';
import 'store_info_screen_button_selector.dart';

import 'package:package_info_plus/package_info_plus.dart';

// ignore: unused_import, avoid_web_libraries_in_flutter
import 'dart:html' as html;

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
              .read(storeWaitingRequestNotifierProvider.notifier)
              .setClient(value);
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
  void didChangeDependencies() async {
    printd("StoreDetailInfoWidget didChangeDependencies");
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    printd("packageInfo: ${packageInfo.version}");
    ref.read(appVersionProvider.notifier).setAppVersion(packageInfo.version);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    printd("StoreDetailInfoWidget dispose");
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printd("StoreDetailInfoWidget build");
    final storeDetailInfo = ref.watch(storeDetailInfoProvider);

    if (storeDetailInfo != null) {
      return NonNullStoreDetailInfoWidget(storeDetailInfo);
      // return TextWidget(
      //     "storeDetailInfo is not null : ${storeDetailInfo.storeCode}");
    } else {
      return Scaffold(
        body:
            CustomLoadingIndicator(who: "StoreDetailInfoWidget buildScaffold"),
      );
    }
  }
}

class NonNullStoreDetailInfoWidget extends ConsumerStatefulWidget {
  final StoreDetailInfo storeDetailInfo;

  const NonNullStoreDetailInfoWidget(
    this.storeDetailInfo, {
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _NonNullStoreDetailInfoWidgetState createState() =>
      _NonNullStoreDetailInfoWidgetState();
}

class _NonNullStoreDetailInfoWidgetState
    extends ConsumerState<NonNullStoreDetailInfoWidget> {
  @override
  void initState() {
    super.initState();
    initializePackageInfo(ref);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.white,
        child: CustomScrollView(
          slivers: [
            // AppBar
            Consumer(
                // Consumer로 감싸서 widget.storeDetailInfoProvider를 감지하고, widget.storeDetailInfo가 변경될 때마다 화면을 갱신
                builder: (context, ref, child) {
              return SliverAppBar(
                backgroundColor: const Color(0xFFFFB74D), // 배경색 설정
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25), // 아래쪽 모서리 둥글게
                    bottomRight: Radius.circular(25),
                  ),
                ),
                leading: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        "assets/images/orre_logo.png",
                        width: 16.sp,
                        height: 16.sp,
                      ),
                    ),
                    SizedBox(width: 5.sp),
                    TextWidget("오리", color: Colors.white, fontSize: 14.sp),
                  ],
                ),
                leadingWidth: 60.sp,
                // leading: IconButton(
                //   // 왼쪽 상단 뒤로가기 아이콘
                //   icon: Icon(Icons.arrow_back, color: Colors.white),
                //   onPressed: () {
                //     Navigator.pop(context);
                //   },
                // ),
                actions: [
                  CallButtonWidget(
                    storePhoneNumber: widget.storeDetailInfo.storePhoneNumber,
                  ),
                  GoogleMapButtonWidget(
                    storeInfo: widget.storeDetailInfo,
                  ),
                ],
                expandedHeight: 240, // 높이 설정
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 12),
                  title: TextWidget(
                    widget.storeDetailInfo.storeName,
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
                            widget.storeDetailInfo.storeImageMain),
                        fit: BoxFit.cover,
                        width: 130,
                        height: 130,
                      ),
                    ),
                  ),
                ),
                pinned: true, // 스크롤시 고정
              );
            }),

            // WaitingStatusWidget
            Consumer(
                // Consumer로 감싸서 widget.storeDetailInfoProvider를 감지하고, widget.storeDetailInfo가 변경될 때마다 화면을 갱신
                builder: (context, ref, child) {
              return WaitingStatusWidget(
                storeCode: widget.storeDetailInfo.storeCode,
                locationInfo: widget.storeDetailInfo.locationInfo,
              );
            }),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(
                    height: 16.h,
                  ),
                  TextWidget("메뉴 사진은 앱 또는 각 항목을 클릭해서 확인 가능합니다.",
                      fontSize: 16.sp),
                  SizedBox(
                    height: 8.h,
                  ),
                  SmallButtonWidget(
                    text: "앱 바로가기",
                    fontSize: 16.sp,
                    minSize: Size(100.w, 40.h),
                    maxSize: Size(100.w, 40.h),
                    onPressed: () async {
                      appNavigatorService(widget.storeDetailInfo, context);
                    },
                  ),
                  SizedBox(
                    height: 32.h,
                  ),
                ],
              ),
            ),

            // MenuCategoryListWidget
            Consumer(
                // Consumer로 감싸서 widget.storeDetailInfoProvider를 감지하고, widget.storeDetailInfo가 변경될 때마다 화면을 갱신
                builder: (context, ref, child) {
              return StoreMenuCategoryListWidget(
                  storeDetailInfo: widget.storeDetailInfo);
            }),

            // 사업자 정보 Footer
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      "단모음데브 대표 정민호 | ",
                      fontSize: 6.sp,
                      color: Colors.grey,
                    ),
                    TextWidget("주소 : 경기도 용인시 기흥구 보정동 1189-3, 3층 일부 | ",
                        fontSize: 6.sp, color: Colors.grey),
                    TextWidget(
                      "사업자 등록번호 865-18-02259 | ",
                      fontSize: 6.sp,
                      color: Colors.grey,
                    ),
                    Consumer(builder: (context, ref, child) {
                      final appVersion = ref.watch(appVersionProvider);
                      return TextWidget(
                        "서비스 버전 : ${getAppVersion()}",
                        fontSize: 6.sp,
                        color: Colors.grey,
                      );
                    }),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48.h,
              ),
            ),
            // PopScope(
            //   child: const SliverToBoxAdapter(
            //     child: SizedBox(
            //       height: 80,
            //     ),
            //   ),
            //   onPopInvoked: (didPop) {
            //     if (didPop) {
            //       ref
            //           .read(storeDetailInfoProvider.notifier)
            //           .clearStoreDetailInfo();
            //     }
            //   },
            // ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          widget.storeDetailInfo != StoreDetailInfo.nullValue()
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: BottomButtonSelector(
                    storeDetailInfo: widget.storeDetailInfo,
                    nowWaitable: widget.storeDetailInfo.waitingAvailable == 0,
                  ),
                )
              : null,
    );
  }
}
