import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:orre_web/presenter/storeinfo/agreement_screen_detail.dart';
import 'package:orre_web/services/debug_services.dart';
import 'package:orre_web/widget/appbar/static_app_bar_widget.dart';
import 'package:orre_web/widget/background/waveform_background_widget.dart';
import 'package:orre_web/widget/button/big_button_widget.dart';
import 'package:orre_web/widget/text/text_widget.dart';

final agreementState = StateProvider<bool>((ref) => false);

class AgreementScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WaveformBackgroundWidget(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height * 0.25),
          child: StaticAppBarWidget(
              title: '오리 서비스 이용약관',
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              )),
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12 * 5),
                Row(
                  children: [
                    Icon(Icons.push_pin),
                    SizedBox(width: 10),
                    TextWidget(
                      '오리 서비스 이용약관 요약',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AgreementScreenDetail())),
                      child: TextWidget(
                        '자세히 보기',
                        fontSize: 12.sp,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.only(left: 35),
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xffDFDFDF), width: 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextWidget(
                                '수집 목적',
                                fontSize: 10.sp,
                                textAlign: TextAlign.start,
                                color: Color(0xFF999999),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: TextWidget(
                                ': 서비스 제공',
                                fontSize: 10.sp,
                                textAlign: TextAlign.start,
                                color: Color(0xFF999999),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextWidget(
                                '수집 항목',
                                fontSize: 10.sp,
                                textAlign: TextAlign.start,
                                color: Color(0xFF999999),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: TextWidget(
                                ': 전화번호',
                                fontSize: 10.sp,
                                textAlign: TextAlign.start,
                                color: Color(0xFF999999),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextWidget(
                                '보유 및 이용 기간',
                                fontSize: 10.sp,
                                textAlign: TextAlign.start,
                                color: Color(0xFF999999),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: TextWidget(
                                ': 비회원의 경우, 해당 매장의 당일 영업 종료 시까지',
                                fontSize: 10.sp,
                                textAlign: TextAlign.start,
                                color: Color(0xFF999999),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: BigButtonWidget(
                    onPressed: () {
                      printd("이용약관에 동의하셨습니다.");
                      ref.read(agreementState.notifier).state = true;
                      Navigator.pop(context);
                    },
                    text: '동의합니다',
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
