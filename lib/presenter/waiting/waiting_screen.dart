import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_web/model/store_waiting_request_model.dart';
import 'package:orre_web/provider/network/https/post_store_info_future_provider.dart';
import 'package:orre_web/provider/network/https/store_detail_info_state_notifier.dart';
import 'package:orre_web/services/debug.services.dart';
import 'package:orre_web/widget/button/big_button_widget.dart';
import 'package:orre_web/widget/loading_indicator/coustom_loading_indicator.dart';
import 'package:orre_web/widget/text/text_widget.dart';
import 'package:orre_web/widget/text_field/text_input_widget.dart';

import '../../provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import '../../provider/network/websocket/store_waiting_info_state_notifier.dart';
import '../storeinfo/store_info_screen.dart';

class WaitingScreen extends ConsumerStatefulWidget {
  const WaitingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends ConsumerState<WaitingScreen> {
  @override
  Widget build(BuildContext context) {
    printd("!!!!!!!!!!!!!!!!!!!");

    final listOfWaitingStoreProvider =
        ref.watch(storeWaitingRequestNotifierProvider);

    printd("listOfWaitingStoreProvider: $listOfWaitingStoreProvider");

    return Scaffold(
      backgroundColor: const Color(0xFFDFDFDF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDFDFDF),
        title: const TextWidget(' '),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(storeWaitingRequestNotifierProvider.notifier)
                  .clearWaitingRequestList();
            },
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(70.0),
              topRight: Radius.circular(70.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const TextWidget(
                '웨이팅 목록',
                fontSize: 42,
                color: Color(0xFFFFB74D),
              ),
              Divider(
                color: const Color(0xFFFFB74D),
                thickness: 3,
                endIndent: MediaQuery.of(context).size.width * 0.25,
                indent: MediaQuery.of(context).size.width * 0.25,
              ),
              const SizedBox(height: 25),
              Expanded(
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (context, irndex) {
                    final item = listOfWaitingStoreProvider;
                    if (item == null) {
                      return const ListTile(
                        title: TextWidget(
                          '줄서기 중인 가게가 없습니다.',
                          color: Color(0xFFDFDFDF),
                        ),
                      );
                    } else {
                      return WaitingStoreItem(item);
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class WaitingStoreItem extends ConsumerWidget {
  final StoreWaitingRequest storeWaitingRequest;

  const WaitingStoreItem(this.storeWaitingRequest, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneNumberTextController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return FutureBuilder(
        future: fetchStoreDetailInfo(
            StoreInfoParams(storeWaitingRequest.token.storeCode, 0)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: CustomLoadingIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return TextWidget('Error: ${snapshot.error}');
          } else {
            final storeDetailInfo = snapshot.data;
            if (storeDetailInfo == null) {
              return const TextWidget('가게 정보를 불러오지 못했습니다.');
            }
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return StoreDetailInfoWidget(phoneNumberTextController.text,
                        storeCode: storeWaitingRequest.token.storeCode);
                  },
                ),
              ),
              child: Form(
                key: formKey,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CachedNetworkImage(
                            imageUrl: storeDetailInfo.storeImageMain,
                            imageBuilder: (context, imageProvider) => Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            placeholder: (context, url) => SizedBox(
                              width: 40,
                              height: 40,
                              child: Center(
                                child: CustomLoadingIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                storeDetailInfo.storeName,
                                textAlign: TextAlign.start,
                                fontSize: 28,
                              ), // 가게 이름 동적으로 표시
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const TextWidget('내 웨이팅 번호는 ', fontSize: 20),
                                  TextWidget(
                                    '${storeWaitingRequest.token.waiting}',
                                    fontSize: 24,
                                    color: const Color(0xFFDD0000),
                                  ),
                                  const TextWidget('번 이예요.', fontSize: 20),
                                ],
                              ),
                              StreamBuilder(
                                  stream: ref
                                      .watch(storeWaitingInfoNotifierProvider
                                          .notifier)
                                      .subscribeToStoreWaitingInfo(
                                          storeDetailInfo.storeCode),
                                  builder: ((context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Center(
                                          child: CustomLoadingIndicator(),
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return TextWidget(
                                          'Error: ${snapshot.error}');
                                    } else {
                                      if (snapshot.data == null) {
                                        return const TextWidget(
                                            '웨이팅 정보를 불러오지 못했어요.');
                                      }
                                      final storeWaitingInfo = snapshot.data;
                                      final myWaitingNumber =
                                          storeWaitingRequest.token.waiting;
                                      final myWaitingIndex = storeWaitingInfo
                                          ?.enteringTeamList
                                          .indexOf(myWaitingNumber);

                                      if (myWaitingIndex == -1 ||
                                          myWaitingIndex == null) {
                                        return const TextWidget(
                                            '대기 중인 팀이 없습니다.');
                                      } else {
                                        return Row(
                                          children: [
                                            const TextWidget(
                                              '내 순서까지  ',
                                              fontSize: 20,
                                              textAlign: TextAlign.start,
                                            ),
                                            TextWidget(
                                              '$myWaitingIndex',
                                              fontSize: 24,
                                              color: const Color(0xFFDD0000),
                                            ),
                                            const TextWidget('팀 남았어요.',
                                                fontSize: 20),
                                          ],
                                        );
                                      }
                                    }
                                  }))
                            ],
                          ),
                        ],
                      ),
                      BigButtonWidget(
                        text: '웨이팅 취소하기',
                        textColor: const Color(0xFF999999),
                        backgroundColor: const Color(0xFFDFDFDF),
                        minimumSize: const Size(double.infinity, 40),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const TextWidget('웨이팅 취소'),
                            content: TextInputWidget(
                              controller: phoneNumberTextController,
                              hintText: '전화번호 입력',
                              type: TextInputType.number,
                              ref: ref,
                              autofillHints: const [
                                AutofillHints.telephoneNumber
                              ],
                              isObscure: false,
                              minLength: 11,
                              maxLength: 11,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const TextWidget('취소'),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: const TextWidget('확인'),
                                onPressed: () {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }
                                  final enteredCode =
                                      phoneNumberTextController.text;
                                  final phoneNumber =
                                      storeWaitingRequest.token.phoneNumber;
                                  printd("enteredCode: $enteredCode");
                                  printd("phoneNumber: $phoneNumber");

                                  if (enteredCode == phoneNumber) {
                                    ref
                                        .read(
                                            storeWaitingRequestNotifierProvider
                                                .notifier)
                                        .sendWaitingCancelRequest(
                                            storeWaitingRequest.token.storeCode,
                                            storeWaitingRequest
                                                .token.phoneNumber);
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: TextWidget(
                                                '전화번호가 일치하지 않습니다.')));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}
