import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orre_web/services/debug_services.dart';
import 'package:orre_web/widget/button/small_button_widget.dart';
import 'package:orre_web/widget/popup/alert_popup_widget.dart';
import 'package:orre_web/widget/text/text_widget.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';

class QRScanButton extends ConsumerWidget {
  const QRScanButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QrScannerScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFB74D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10.h),
          Icon(Icons.qr_code_scanner, size: 32.sp, color: Colors.white),
          TextWidget(
            'QR 코드 스캔',
            fontSize: 12.sp,
            color: Colors.white,
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _QrScannerScreenState createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    // 웹에서 카메라 권한 요청
    // ignore: avoid_print
    print('카메라 권한 요청');

    return Scaffold(
      // backgroundColor: const Color(0xFFFFB74D),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const TextWidget('QR Code 스캔', color: Colors.white),
        backgroundColor: const Color(0xFFFFB74D),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRCodeDartScanView(
              scanInvertedQRCode:
                  true, // enable scan invert qr code ( default = false)

              typeScan: TypeScan
                  .takePicture, // if TypeScan.takePicture will try decode when click to take a picture(default TypeScan.live)
              // intervalScan: const Duration(seconds: 1),
              // onResultInterceptor: (){
              // //  do any rule to controll onCapture.
              // },
              takePictureButtonBuilder: (context, controller, isLoading) {
                // if typeScan == TypeScan.takePicture you can customize the button.
                if (isLoading) {
                  return const Center(
                    heightFactor: 3,
                    child: CircularProgressIndicator(color: Color(0xFFFFB74D)),
                  );
                }
                return Center(
                  heightFactor: 3,
                  child: SmallButtonWidget(
                    minSize: const Size(100, 50),
                    text: '촬영하기',
                    onPressed: () {
                      controller.takePictureAndDecode();
                    },
                  ),
                );
              },
              onCapture: (data) async {
                printd('onCapture: $data');
                _checkUrl(data.toString()).then((value) {
                  if (value != null) {
                    context.go('/reservation/$value');
                    Navigator.pop(context);
                  } else {
                    // 잘못된 URL이 입력되었을 때
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertPopupWidget(
                          title: 'QR 코드 스캔 실패',
                          subtitle: '잘못된 QR 코드입니다.',
                          buttonText: '확인',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // 정해진 URL로 입력을 받았는 지 확인하는 함수
  Future<String?> _checkUrl(String url) async {
    if (url.contains(dotenv.get('ORRE_CHECK_URL_1')) ||
        url.contains(dotenv.get('ORRE_CHECK_URL_2')) ||
        url.contains(dotenv.get('ORRE_CHECK_URL_3')) ||
        url.contains(dotenv.get('ORRE_CHECK_URL_4')) ||
        url.contains(dotenv.get('ORRE_CHECK_URL_5'))) {
      printd('URL: $url');
      // reservation 뒤의 숫자(자릿수 상관 없음)를 추출하되, 다른 그 이후의 다른 문자열은 무시
      final storeCode = int.tryParse(
          url.substring(url.indexOf('reservation/') + 12, url.length));

      // storeCode를 문자열로 변환하여 반환
      return storeCode.toString();
    } else {
      printd('오리가 서비스하는 URL이 아닙니다.');
      return null;
    }
  }
}
