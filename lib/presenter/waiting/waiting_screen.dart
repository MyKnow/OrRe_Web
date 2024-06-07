// ignore_for_file: unused_local_variable, unused_import, avoid_web_libraries_in_flutter

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_web/presenter/storeinfo/google_map_button_widget.dart';
import 'package:orre_web/presenter/storeinfo/store_call_button_widget.dart';
import 'package:orre_web/presenter/storeinfo/store_info_screen_waiting_dialog.dart';
import 'package:orre_web/provider/network/https/get_service_log_state_notifier.dart';
import 'package:orre_web/provider/network/websocket/stomp_client_state_notifier.dart';
import 'package:orre_web/provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import 'package:orre_web/provider/waiting_usercall_time_list_state_notifier.dart';
import 'package:orre_web/services/app_navigator_service.dart';
import 'package:orre_web/services/debug_services.dart';
import 'package:orre_web/widget/button/big_button_widget.dart';
import 'package:orre_web/widget/loading_indicator/coustom_loading_indicator.dart';
import 'package:orre_web/widget/popup/alert_popup_widget.dart';
import 'package:orre_web/widget/text/text_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../provider/app_state_provider.dart';
import '../../provider/network/websocket/store_detail_info_state_notifier.dart';
import '../../provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import '../../provider/network/websocket/store_waiting_info_state_notifier.dart';
import '../../services/app_version_service.dart';
import '../../widget/button/small_button_widget.dart';
import 'waiting_screen_menu_category_list_widget.dart';

import 'dart:html' as html;

class WaitingScreen extends ConsumerStatefulWidget {
  final int storeCode;
  final String userPhoneNumber;
  const WaitingScreen(
      {super.key, required this.storeCode, required this.userPhoneNumber});

  @override
  // ignore: library_private_types_in_public_api
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends ConsumerState<WaitingScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(stompClientStateNotifierProvider) == null) {
        printd("stompClientStateNotifierProvider is null");
        ref.read(stompClientStateNotifierProvider.notifier).configureClient();
      }
      if (ref.read(waitingSuccessDialogProvider) == true) {
        showDialog(
          context: context,
          builder: (context) => const AlertPopupWidget(
            title: '웨이팅 성공',
            subtitle: '웨이팅이 성공적으로 시작되었습니다.',
            buttonText: '확인',
          ),
        );
      } else if (ref.read(waitingSuccessDialogProvider) == false) {
        showDialog(
          context: context,
          builder: (context) => const AlertPopupWidget(
            title: '웨이팅 존재',
            subtitle: '이미 웨이팅 중인 가게입니다.',
            buttonText: '확인',
          ),
        );
      }
      ref.read(waitingSuccessDialogProvider.notifier).state = null;
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    printd("packageInfo: ${packageInfo.version}");
    ref.read(appVersionProvider.notifier).setAppVersion(packageInfo.version);
    ref
        .refresh(serviceLogProvider.notifier)
        .fetchStoreServiceLog(widget.userPhoneNumber);
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
        break;
      case AppLifecycleState.resumed:
        printd('App is in foreground');
        ref
            .refresh(serviceLogProvider.notifier)
            .fetchStoreServiceLog(widget.userPhoneNumber);
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
    printd("WaitingScreen build");

    final userStatus = ref.watch(waitingStatus);

    return Scaffold(
      backgroundColor: const Color(0xFFDFDFDF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDFDFDF),
        title: const TextWidget(' '),
        actions: const [],
        toolbarHeight: 8.r,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(70.0),
              topRight: Radius.circular(70.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 8.r),
              TextWidget(
                '웨이팅 조회',
                fontSize: 24.sp,
                color: const Color(0xFFFFB74D),
              ),
              Divider(
                color: const Color(0xFFFFB74D),
                thickness: 3.r,
                endIndent: 0.3.sw,
                indent: 0.3.sw,
              ),
              SizedBox(height: 8.r),
              Expanded(
                child: FutureBuilder(
                    future: ref
                        .watch(serviceLogProvider.notifier)
                        .fetchStoreServiceLog(widget.userPhoneNumber),
                    builder: (context, snapshot) {
                      printd("ServiceLog snapshot.data: ${snapshot.data}");
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CustomLoadingIndicator(
                              who: "waiting screen service log futureBuilder"),
                        );
                      } else if (snapshot.hasData) {
                        final storeServiceLog = snapshot.data!;
                        final userLog = storeServiceLog.userLogs.lastOrNull;

                        if (userLog == null) {
                          return TextWidget('웨이팅 중인 가게가 없습니다.', fontSize: 16.r);
                        }

                        if (userLog.status ==
                                StoreWaitingStatus.USER_CANCELED ||
                            userLog.status ==
                                StoreWaitingStatus.STORE_CANCELED) {
                          return Column(
                            children: [
                              SizedBox(height: 20.r),
                              TextWidget('현재 가게는 웨이팅이 취소되었습니다.',
                                  fontSize: 24.r),
                              SizedBox(height: 16.r),
                              BigButtonWidget(
                                text: '홈으로 돌아가기',
                                minimumSize: Size(0.5.sw, 50.r),
                                maximumSize: Size(0.5.sw, 50.r),
                                textColor: Colors.white,
                                textSize: 16.r,
                                onPressed: () async {
                                  final storeCode = widget.storeCode;
                                  final base = Uri.base;
                                  printd("base: $base");
                                  // base에서 마지막 엔드포인트(/01092566504와 같은 번호) 제거
                                  final reservationUrlString = base
                                      .toString()
                                      .split('/')
                                      .sublist(0,
                                          base.toString().split('/').length - 1)
                                      .join('/');
                                  final reservationUrl =
                                      Uri.parse(reservationUrlString);
                                  final baseUri =
                                      base.toString().split('/').first;
                                  printd("reservationUrl: $reservationUrl");
                                  if (await canLaunchUrl(reservationUrl)) {
                                    launchUrl(reservationUrl,
                                        mode: LaunchMode.inAppBrowserView);
                                  } else {
                                    throw 'Could not launch $reservationUrl';
                                  }
                                  // ref
                                  //     .read(storeDetailInfoProvider.notifier)
                                  //     .clearStoreDetailInfo();

                                  // ref
                                  //     .read(storeDetailInfoProvider.notifier)
                                  //     .clearStoreDetailInfo();
                                  // ref
                                  //     .read(storeWaitingRequestNotifierProvider
                                  //         .notifier)
                                  //     .clearWaitingRequestList();
                                  // ref
                                  //     .read(storeWaitingInfoNotifierProvider
                                  //         .notifier)
                                  //     .clearWaitingInfo();
                                  // ref
                                  //     .read(storeWaitingUserCallNotifierProvider
                                  //         .notifier)
                                  //     .unSubscribe();
                                  // context.go('/reservation/$storeCode');
                                },
                              ),
                            ],
                          );
                        }

                        final stomp =
                            ref.watch(stompClientStateNotifierProvider);
                        printd("stompActive: ${stomp?.isActive}");
                        printd("stompConnected: ${stomp?.connected}");
                        if (stomp?.isActive == true &&
                            stomp?.connected == true) {
                          Future.delayed(Duration.zero, () {
                            ref
                                .read(serviceLogProvider.notifier)
                                .reconnectWebsocketProvider(userLog);
                          });
                        }

                        if (userLog.storeCode != widget.storeCode) {
                          return TextWidget('현재 웨이팅 중인 가게가 아닙니다.',
                              fontSize: 16.r);
                        } else {
                          final stomp =
                              ref.watch(stompClientStateNotifierProvider);
                          final stompStatus = ref.watch(stompState);
                          printd("stomp 재연결 로직 : ${userLog.status}");

                          if (stomp == null) {
                            printd("stomp null: $stomp");
                          } else {
                            printd("stomp not null: $stomp");

                            if (stompStatus == StompStatus.DISCONNECTED) {
                              printd("stomp is not activated");
                            } else if (stomp.isActive) {
                              ref
                                  .read(storeDetailInfoProvider.notifier)
                                  .setClient(stomp);
                              ref
                                  .read(storeWaitingRequestNotifierProvider
                                      .notifier)
                                  .setClient(stomp);
                              ref
                                  .read(
                                      storeWaitingInfoNotifierProvider.notifier)
                                  .setClient(stomp);
                              ref
                                  .read(storeWaitingUserCallNotifierProvider
                                      .notifier)
                                  .setClient(stomp);
                              printd("stomp 변경");
                              printd("stomp is activated?: ${stomp.isActive}");
                              printd("stomp is connected?: ${stomp.connected}");
                              if (ref
                                  .read(storeDetailInfoProvider.notifier)
                                  .isClientConnected()) {
                                printd("stomp is connected");
                                return WaitingStoreItem(userLog: userLog);
                              } else {
                                printd("stomp is not connected");
                                ref
                                    .read(storeDetailInfoProvider.notifier)
                                    .setClient(stomp);
                              }
                            }
                          }
                          return Center(
                            child: CustomLoadingIndicator(
                                who: "waiting screen builder"),
                          );
                        }
                      } else {
                        return TextWidget('웨이팅 중인 가게가 없습니다.', fontSize: 16.r);
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaitingStoreItem extends ConsumerStatefulWidget {
  final UserLogs userLog;

  const WaitingStoreItem({super.key, required this.userLog});

  @override
  _WaitingStoreItemState createState() =>
      _WaitingStoreItemState(userLog: userLog);
}

class _WaitingStoreItemState extends ConsumerState<WaitingStoreItem> {
  final UserLogs userLog;

  _WaitingStoreItemState({required this.userLog});

  @override
  void initState() {
    super.initState();
    initializePackageInfo(ref);
  }

  @override
  Widget build(BuildContext context) {
    printd("WaitingStoreItem build");
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final storeCode = userLog.storeCode;
    final storeInfo = ref.watch(storeDetailInfoProvider);

    if (storeInfo == null) {
      Future.delayed(Duration.zero, () {
        ref
            .read(storeDetailInfoProvider.notifier)
            .subscribeStoreDetailInfo(storeCode);
        ref
            .read(storeDetailInfoProvider.notifier)
            .sendStoreDetailInfoRequest(storeCode);
      });
      return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomLoadingIndicator(who: "waiting store item build"),
              SizedBox(height: 16.r),
              TextWidget('가게 정보를 불러오는 중입니다.', fontSize: 24.r),
            ]),
      );
    } else {
      return GestureDetector(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) {
          //       return StoreDetailInfoWidget(
          //           phoneNumberTextController.text,
          //           storeCode: userLog.storeCode);
          //     },
          //   ),
          // );
        },
        child: Form(
          key: formKey,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8.0.r, horizontal: 24.0.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 가게 이미지 위젯
                    Container(
                      width: 80.r,
                      height: 80.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.0.r),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: storeInfo.storeImageMain,
                        width: 80.r,
                        height: 80.r,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) {
                          return Container(
                            width: 80.r,
                            height: 80.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10.0.r),
                            ),
                            child: Icon(
                              Icons.no_food_rounded,
                              color: Colors.white,
                              size: 60.r,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16.r),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 가게 이름 위젯
                        Row(
                          children: [
                            TextWidget(
                              storeInfo.storeName,
                              textAlign: TextAlign.start,
                              fontSize: 24.r,
                            ),
                            SizedBox(width: 8.r),
                            // 가게 전화 버튼
                            CallButtonWidget(
                              storePhoneNumber: storeInfo.storePhoneNumber,
                              iconColor: const Color(0xFFFFB74D),
                            ),
                            SizedBox(width: 2.r),
                            // 구글맵 버튼
                            GoogleMapButtonWidget(
                              storeInfo: storeInfo,
                              iconColor: const Color(0xFFFFB74D),
                            ),
                          ],
                        ),

                        // 유저 상태 및 유저 웨이팅 번호 위젯
                        Row(
                          children: [
                            // 유저 상태 위젯
                            TextWidget(
                              userLog.status == StoreWaitingStatus.WAITING
                                  ? '대기 중'
                                  : userLog.status == StoreWaitingStatus.CALLED
                                      ? '호출 됨'
                                      : userLog.status ==
                                              StoreWaitingStatus.ENTERD
                                          ? '입장 완료'
                                          : userLog.status ==
                                                  StoreWaitingStatus
                                                      .USER_CANCELED
                                              ? '입장 취소'
                                              : userLog.status ==
                                                      StoreWaitingStatus
                                                          .STORE_CANCELED
                                                  ? '입장 거절'
                                                  : '',
                              fontSize: 12.r,
                              color: const Color(0xFFDD0000),
                            ),
                            Divider(
                              color: const Color(0xFFDD0000),
                              thickness: 4.r,
                              endIndent: 4.r,
                              indent: 4.r,
                            ),
                            // 웨이팅 번호 위젯
                            Row(
                              children: [
                                TextWidget('내 웨이팅 번호는  ', fontSize: 12.r),
                                TextWidget(
                                  '${userLog.waiting}',
                                  fontSize: 16.r,
                                  color: const Color(0xFFDD0000),
                                ),
                                TextWidget(' 번이예요.', fontSize: 12.r),
                              ],
                            ),
                          ],
                        ),

                        if (userLog.status == StoreWaitingStatus.CALLED)
                          TextWidget(
                              '입장 마감까지 ${ref.watch(waitingUserCallTimeListProvider)?.inSeconds ?? "0"}초 남았습니다.',
                              fontSize: 12.r)
                        else if (userLog.status == StoreWaitingStatus.ENTERD)
                          TextWidget('입장이 완료되었습니다.', fontSize: 12.r)
                        // 대기 팀 수 위젯
                        else
                          StreamBuilder(
                            stream: ref
                                .watch(
                                    storeWaitingInfoNotifierProvider.notifier)
                                .stream,
                            builder: ((context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                Future.delayed(Duration.zero, () {
                                  ref
                                      .read(storeWaitingInfoNotifierProvider
                                          .notifier)
                                      .subscribeToStoreWaitingInfo(
                                          storeInfo.storeCode);
                                  ref
                                      .read(storeWaitingInfoNotifierProvider
                                          .notifier)
                                      .sendStoreCode(storeInfo.storeCode);
                                });
                                return Row(
                                  children: [
                                    TextWidget('정보를 불러오는 중..', fontSize: 12.sp),
                                    SizedBox(width: 16.w),
                                    SmallButtonWidget(
                                        text: "새로고침",
                                        fontSize: 8.sp,
                                        minSize: Size(50.w, 40.h),
                                        maxSize: Size(50.w, 40.h),
                                        onPressed: () {
                                          ref
                                              .read(
                                                  storeWaitingInfoNotifierProvider
                                                      .notifier)
                                              .clearWaitingInfo();
                                          ref
                                              .read(
                                                  storeWaitingInfoNotifierProvider
                                                      .notifier)
                                              .subscribeToStoreWaitingInfo(
                                                  storeInfo.storeCode);
                                          ref
                                              .read(
                                                  storeWaitingInfoNotifierProvider
                                                      .notifier)
                                              .sendStoreCode(
                                                  storeInfo.storeCode);
                                        }),
                                  ],
                                );
                              } else if (snapshot.data == null) {
                                // Future.delayed(Duration.zero, () {
                                //   ref
                                //       .read(storeWaitingInfoNotifierProvider
                                //           .notifier)
                                //       .clearWaitingInfo();
                                //   ref
                                //       .read(storeWaitingInfoNotifierProvider
                                //           .notifier)
                                //       .sendStoreCode(storeInfo.storeCode);
                                // });
                                return TextWidget(
                                  '웨이팅 정보를 불러오지 못했어요.',
                                  fontSize: 12.r,
                                );
                              }
                              final storeWaitingInfo = snapshot.data;
                              final myWaitingNumber = userLog.waiting;
                              printd("myWaitingNumber: $myWaitingNumber");
                              printd(
                                  "enteringTeamList: ${storeWaitingInfo?.waitingTeamList}");
                              final myWaitingIndex = storeWaitingInfo
                                  ?.waitingTeamList
                                  .indexOf(myWaitingNumber);
                              // final storeEnteringTeamList =
                              //     storeWaitingInfo?.enteringTeamList;
                              // final isMyEnteringTime = storeEnteringTeamList
                              //     ?.contains(myWaitingNumber);
                              final userCallTime =
                                  ref.watch(waitingUserCallTimeListProvider);

                              if (userCallTime != null) {
                                final userCallTimeInSeconds =
                                    userCallTime.inSeconds.toString();
                                return TextWidget(
                                    '입장 마감 시간까지 $userCallTimeInSeconds초 남았어요.',
                                    fontSize: 12.r);
                                // } else if (isMyEnteringTime == true) {
                                //   return TextWidget('곧 입장할 차례입니다!',
                                //       fontSize: 12.r);
                              } else if (myWaitingIndex == -1 ||
                                  myWaitingIndex == null) {
                                return TextWidget('대기 중인 팀이 없습니다.',
                                    fontSize: 12.r);
                              } else {
                                return Row(
                                  children: [
                                    TextWidget(
                                      '내 순서까지  ',
                                      fontSize: 12.r,
                                      textAlign: TextAlign.start,
                                    ),
                                    TextWidget(
                                      '$myWaitingIndex',
                                      fontSize: 16.r,
                                      color: const Color(0xFFDD0000),
                                    ),
                                    TextWidget(' 팀 남았어요.', fontSize: 12.r),
                                  ],
                                );
                              }
                            }),
                          ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.r),
                if (userLog.status != StoreWaitingStatus.ENTERD)
                  BigButtonWidget(
                    text: '웨이팅 취소하기',
                    textSize: 16.sp,
                    textColor: Colors.white,
                    backgroundColor: const Color(0xFFFFB74D),
                    minimumSize: Size(0.9.sw, 40.r),
                    maximumSize: Size(0.9.sw, 50.r),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => AlertPopupWidget(
                          title: '웨이팅 취소',
                          subtitle: '웨이팅을 취소하시겠습니까?',
                          onPressed: () {
                            ref
                                .read(storeWaitingRequestNotifierProvider
                                    .notifier)
                                .sendWaitingCancelRequest(
                                    storeCode, userLog.userPhoneNumber);

                            ref
                                .read(storeDetailInfoProvider.notifier)
                                .clearStoreDetailInfo();
                            ref
                                .read(storeWaitingRequestNotifierProvider
                                    .notifier)
                                .clearWaitingRequestList();
                            ref
                                .read(storeWaitingInfoNotifierProvider.notifier)
                                .clearWaitingInfo();
                            ref
                                .read(storeWaitingUserCallNotifierProvider
                                    .notifier)
                                .unSubscribe();
                            context.go('/reservation/$storeCode');
                          },
                          cancelButton: true,
                          cancelButtonText: '아니요',
                          buttonText: '네'),
                    ),
                  ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget("메뉴 사진은 앱 또는 각 항목을 클릭해서 확인 가능합니다.",
                        fontSize: 10.sp),
                    SizedBox(
                      width: 8.w,
                    ),
                    SmallButtonWidget(
                      fontSize: 12.sp,
                      minSize: Size(70.w, 20.sp),
                      maxSize: Size(70.w, 20.sp),
                      text: "앱 바로가기",
                      onPressed: () async {
                        appNavigatorService(storeInfo, context);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // StoreDetailInfo의 Menu를 출력하는 Scrollview 위젯
                Expanded(
                  child: SingleChildScrollView(
                    child: WaitingScreenStoreMenuCategoryListWidget(
                      storeDetailInfo: storeInfo,
                    ),
                  ),
                ),
                // 사업자 정보 Footer
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextWidget(
                        "단모음데브 대표 정민호 | ",
                        fontSize: 5.sp,
                        color: Colors.grey,
                      ),
                      TextWidget("주소 : 경기도 용인시 기흥구 보정동 1189-3, 3층 일부 | ",
                          fontSize: 5.sp, color: Colors.grey),
                      TextWidget(
                        "사업자 등록번호 865-18-02259 | ",
                        fontSize: 5.sp,
                        color: Colors.grey,
                      ),
                      Consumer(builder: (context, ref, child) {
                        final appVersion = ref.watch(appVersionProvider);
                        return TextWidget(
                          "서비스 버전 : ${getAppVersion()}",
                          fontSize: 5.sp,
                          color: Colors.grey,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
