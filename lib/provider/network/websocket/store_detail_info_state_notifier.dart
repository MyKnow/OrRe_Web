import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_web/services/debug_services.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orre_web/model/store_info_model.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

final storeInfoTrigger = StateProvider<bool?>((ref) {
  return null;
});

final storeDetailInfoProvider =
    StateNotifierProvider<StoreDetailInfoStateNotifier, StoreDetailInfo?>(
        (ref) {
  return StoreDetailInfoStateNotifier();
});

class StoreDetailInfoStateNotifier extends StateNotifier<StoreDetailInfo?> {
  StoreDetailInfoStateNotifier() : super(null) {}
  StompClient? _client;
  // final _storage = FlutterSecureStorage();

  Map<dynamic, dynamic> _subscribeStoreInfo = {};
  int storeCodeForRequest = -1;

  void setClient(StompClient client) {
    // Set the client here
    printd("StoreDetailInfoStateNotifier setClient");
    _client = client;
    printd("client is connected : ${_client?.connected}");
  }

  bool isClientConnected() {
    return _client?.connected ?? false;
  }

  Stream<StoreDetailInfo?> subscribeStoreDetailInfo(int storeCode) {
    StreamController<StoreDetailInfo?> streamController =
        StreamController<StoreDetailInfo?>.broadcast();
    printd(
        "StoreDetailInfoStateNotifier subscribeStoreDetailInfo : $storeCode");
    if (_client == null) {
      printd(
          "StoreDetailInfoStateNotifier subscribeStoreDetailInfo : client is null");
      return Stream.value(state);
    }
    if (_subscribeStoreInfo[storeCode.toString()] == null) {
      _subscribeStoreInfo[storeCode.toString()] = _client?.subscribe(
          destination:
              '${dotenv.get('ORRE_WEBSOCKET_ENDPOINT_STOREDETAILINFO_SUBSCRIBE')}$storeCode',
          callback: (frame) {
            if (frame.body != null) {
              var decodedBody = json.decode(frame.body!);

              final newState = StoreDetailInfo.fromJson(decodedBody);

              // 이전 상태와 현재 들어온 값이 동일하다면 state 변경하지 않음
              if (state == null || state != newState) {
                state = newState;
                printd(
                    "StoreDetailInfoStateNotifier subscribeStoreDetailInfo : ${decodedBody.toString().length}");
                streamController.add(state);
              } else {
                printd(
                    "StoreDetailInfoStateNotifier subscribeStoreDetailInfo : same state");
              }
            }
          });
    } else {
      printd(
          "StoreDetailInfoStateNotifier subscribeStoreDetailInfo : already subscribed");
      streamController.add(state);
    }
    return streamController.stream;
  }

  void sendStoreDetailInfoRequest(int storeCode) {
    printd(
        "StoreDetailInfoStateNotifier sendStoreDetailInfoRequest : $storeCode");
    storeCodeForRequest = storeCode;
    _client?.send(
        destination:
            dotenv.get('ORRE_WEBSOCKET_ENDPOINT_STOREDETAILINFO_REQUEST') +
                storeCode.toString(),
        body: json.encode({'storeCode': storeCode}));
  }

  void clearStoreDetailInfo() {
    printd("StoreDetailInfoStateNotifier clearStoreDetailInfo");
    _subscribeStoreInfo.forEach((key, value) {
      _subscribeStoreInfo[key](unsubscribeHeaders: <String, String>{});
    });
    _subscribeStoreInfo.clear();
    state = null;
  }

  // 앱 전경 진입 시 StoreInfo 재구독 및 요청
  void reSubscribeStoreDetailInfo() {
    printd("StoreDetailInfoStateNotifier reSubscribeStoreDetailInfo");
    if (storeCodeForRequest != -1) {
      clearStoreDetailInfo();
      subscribeStoreDetailInfo(storeCodeForRequest);
      sendStoreDetailInfoRequest(storeCodeForRequest);
    }
  }
}
