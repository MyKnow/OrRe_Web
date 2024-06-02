import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:orre_web/model/store_info_model.dart';
import 'package:orre_web/widget/button/big_button_widget.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:orre_web/presenter/qr_scanner_widget.dart';
import 'package:orre_web/presenter/waiting/waiting_screen.dart';
import 'package:orre_web/services/debug.services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_web/services/nfc_services.dart';
import 'package:orre_web/widget/background/waveform_background_widget.dart';
import 'package:orre_web/widget/popup/alert_popup_widget.dart';
import 'package:orre_web/widget/text/text_widget.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_strategy/url_strategy.dart';

import 'presenter/storeinfo/store_info_screen.dart';

class RouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print("DidPush: $route");
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print("DidPop: $route");
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print("DidRemove: $route");
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    print("DidReplace: $newRoute");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, _) => Builder(
        builder: (context) => MaterialApp.router(
          routerConfig: _router,
          title: '오리',
          theme: ThemeData(
            primaryColor: const Color(0xFFFFB74D),
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFFFFB74D)),
          ),
        ),
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: "/",
  observers: [RouterObserver()],
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        printd("Navigating to HomePage, fullPath: ${state.fullPath}");
        return const HomePage();
      },
    ),
    GoRoute(
      path: '/reservation/:storeCode',
      builder: (context, state) {
        StoreDetailInfo? info = state.extra as StoreDetailInfo?;

        printd("Navigating to ReservationPage, fullPath: ${state.fullPath}");
        printd("Extra: $info");
        if (info == null) {
          final storeCode = int.parse(state.pathParameters['storeCode']!);
          return StoreDetailInfoWidget(null, storeCode: storeCode);
        } else {
          return NonNullStoreDetailInfoWidget(info);
        }
      },
    ),
    GoRoute(
      path: '/reservation/:storeCode/:userPhoneNumber',
      builder: (context, state) {
        printd(
            "Navigating to ReservationPage for Specific User, fullPath: ${state.fullPath}");
        final storeCode = int.parse(state.pathParameters['storeCode']!);
        final userPhoneNumber =
            state.pathParameters['userPhoneNumber']!.replaceAll('-', '');
        return WaitingScreen(
            storeCode: storeCode, userPhoneNumber: userPhoneNumber);
      },
    ),
  ],
  errorBuilder: (context, state) {
    printd('Error: ${state.error}');
    return ErrorPage(state.error);
  },
);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
    String? code;
    return Scaffold(
      body: WaveformBackgroundWidget(
        backgroundColor: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
              TextWidget(
                '오리',
                fontFamily: 'Dovemayo_gothic',
                fontSize: 48.sp,
                color: const Color(0xFFFFB74D),
                letterSpacing: 32.sp,
              ),
              const SizedBox(
                height: 20,
              ),
              ClipOval(
                child: Container(
                  color: const Color(0xFFFFB74D),
                  child: Image.asset(
                    "assets/images/orre_logo.png",
                    width: 0.3.sh,
                    height: 0.3.sh,
                  ),
                ),
              ),
              TextWidget(
                '원격 줄서기, 원격 주문 서비스',
                fontFamily: 'Dovemayo_gothic',
                fontSize: 16.sp,
                color: const Color(0xFFFFB74D),
              ),
              BigButtonWidget(
                  text: 'storeInfo',
                  onPressed: () {
                    context.go('/reservation/1');
                  }),
              const Spacer(),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        distance: 100.0,
        type: ExpandableFabType.side,
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Icons.menu_open_sharp),
          fabSize: ExpandableFabSize.large,
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFFFFB74D),
          shape: const CircleBorder(),
        ),
        closeButtonBuilder: RotateFloatingActionButtonBuilder(
          fabSize: ExpandableFabSize.large,
          child: const Icon(Icons.close_fullscreen),
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFFFFB74D),
          shape: const CircleBorder(),
        ),
        children: [
          // ElevatedButton(
          //   onPressed: () async {
          //     var res = await Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => const SimpleBarcodeScannerPage(),
          //         ));
          //     if (res != null) {
          //       showDialog(
          //         context: context,
          //         builder: (context) => AlertPopupWidget(
          //           title: "바코드 스캔 결과",
          //           multiLineText: res,
          //           buttonText: '확인',
          //           cancelButton: false,
          //         ),
          //       );
          //     }
          //   },
          //   child: const Text('Open Scanner'),
          // ),
          FloatingActionButton.large(
            heroTag: 'qr',
            shape: const CircleBorder(),
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFFFFB74D),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QrScannerScreen()),
            ),
            tooltip: 'QR코드 스캔',
            child: const Icon(Icons.qr_code_scanner_rounded),
          ),
          FloatingActionButton.large(
            heroTag: 'nfc',
            shape: const CircleBorder(),
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFFFFB74D),
            onPressed: () {
              if (UniversalPlatform.isWeb) {
                showDialog(
                  context: context,
                  builder: (context) => const AlertPopupWidget(
                    title: "NFC 스캔 오류",
                    multiLineText:
                        "웹에서는 NFC 스캔을 지원하지 않습니다.\n바탕화면에서 바로 태그를 스캔해주세요.",
                    buttonText: '확인',
                    cancelButton: false,
                  ),
                );
              } else {
                startNFCScan(ref, context);
              }
            },
            tooltip: 'NFC 스캔',
            child: const Icon(Icons.nfc_rounded),
          ),
          // 오리와 계약을 원하시는 업체는 아래 버튼을 눌러주세요.
          FloatingActionButton.large(
            heroTag: 'contract',
            shape: const CircleBorder(),
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFFFFB74D),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertPopupWidget(
                  title: "오리와 함께 웨이팅 서비스를 시작해보세요!",
                  subtitle: "아래 버튼을 눌러주세요.",
                  buttonText: '계약 방법 보기',
                  cancelButton: true,
                  onPressed: () {
                    // 다른 웹페이지 링크로 이동
                    launchUrl(Uri.parse(
                        'https://aeioudev.notion.site/db6980c4bb4748e1a73cc9ce83b033bc?pvs=4'));
                  },
                ),
              );
            },
            tooltip: '오리와 계약',
            child: const Icon(Icons.business_rounded),
          ),
        ],
      ),
    );
  }
}

class ErrorPage extends StatelessWidget {
  final Exception? error;

  const ErrorPage(this.error, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextWidget('Error'),
      ),
      body: Center(
        child: Text(error?.toString() ?? 'Unknown error'),
      ),
    );
  }
}
