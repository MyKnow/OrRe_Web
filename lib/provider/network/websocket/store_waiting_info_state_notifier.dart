import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_web/services/debug_services.dart';
import 'package:orre_web/model/store_waiting_info_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

final waitingTeamListProvider = StreamProvider<List<int>>((ref) {
  final storeWaitingInfo = ref.watch(storeWaitingInfoNotifierProvider);
  return Stream<List<int>>.value(storeWaitingInfo?.waitingTeamList ?? []);
});

final storeWaitingInfoNotifierProvider =
    StateNotifierProvider<StoreWaitingInfoNotifier, StoreWaitingInfo?>((ref) {
  return StoreWaitingInfoNotifier();
});

class StoreWaitingInfoNotifier extends StateNotifier<StoreWaitingInfo?> {
  StompClient? _client;
  dynamic _subscriptions = {};
  int storeCodeForRequest = -1;

  StoreWaitingInfoNotifier() : super(null);

  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient client) {
    printd("StoreWaitingInfo : setClient");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
  }

  bool isClientConnected() {
    return _client?.connected ?? false;
  }

  Stream<StoreWaitingInfo> subscribeToStoreWaitingInfo(int storeCode) {
    StreamController<StoreWaitingInfo> controller = StreamController();
    printd("subscribeToStoreWaitingInfo : $storeCode");

    if (storeCodeForRequest == storeCode) {
      printd("subscribeToStoreWaitingInfo already : $storeCode");
      return controller.stream;
    }
    _subscriptions = _client?.subscribe(
      destination:
          dotenv.get('ORRE_WEBSOCKET_ENDPOINT_STOREWAITINGINFO_SUBSCRIBE') +
              storeCode.toString(),
      callback: (frame) {
        if (frame.body != null) {
          var decodedBody = json.decode(frame.body!); // JSON 문자열을 객체로 변환
          if (decodedBody is Map<String, dynamic>) {
            // 첫 번째 요소를 추출하고 StoreWaitingInfo 인스턴스로 변환
            var firstResult = StoreWaitingInfo.fromJson(decodedBody);

            // 이전 상태와 현재 들어온 값이 동일하다면 state 변경하지 않음
            if (state == null || state != firstResult) {
              // 해당 요소로 state 업데이트
              state = firstResult;
              controller.add(firstResult);
              printd("subscribeToStoreWaitingInfo state : $state");
            } else {
              printd("subscribeToStoreWaitingInfo state is same");
            }
          }
        }
      },
    );
    storeCodeForRequest = storeCode;
    return controller.stream;
  }

  // 사용자의 위치 정보를 서버로 전송하는 메소드
  void sendStoreCode(int storeCode) {
    printd("sendStoreCode : $storeCode");
    _client?.send(
      destination:
          dotenv.get('ORRE_WEBSOCKET_ENDPOINT_STOREWAITINGINFO_REQUEST') +
              storeCode.toString(),
      body: json.encode({"storeCode": storeCode}),
    );
  }

  void unSubscribe() {
    printd("unSubscribe StoreWaitingInfo");

    _subscriptions(unsubscribeHeaders: <String, String>{});

    printd("subscribedsubscriptionsStoreCodes : $_subscriptions");

    _subscriptions = {};
    storeCodeForRequest = -1;
  }

  List<int> getWaitingTeamsList(int storeCode) {
    if (state != null) {
      return state!.waitingTeamList;
    } else {
      return [];
    }
  }

  void clearWaitingInfo() {
    printd("clearStoreWaitingInfo");
    unSubscribe();
    state = null;
  }

  void saveState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedList = json.encode(StoreWaitingInfo);
    // printd("waitingInfoList saveState encodedList : $encodedList");
    prefs.setString('waitingInfoList', encodedList);
  }

  void loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encodedJson = prefs.getString('waitingInfoList');
    if (encodedJson != null) {
      printd("waitingInfoList loadState encodedList : $encodedJson");
      var decodedJson = json.decode(encodedJson);
      state = StoreWaitingInfo.fromJson(decodedJson);
      // saveState();
    }
  }

  void reconnect() {
    printd("reconnect");
    _client?.activate();
    loadState();
    if (state != null) {
      printd("reconnect : ${state?.storeCode}");
      subscribeToStoreWaitingInfo(state!.storeCode);
    } else {
      printd("reconnect : state is null");
    }
  }

  void reconnectByState() {
    printd("reconnectByState");
    if (state != null) {
      printd("reconnectByState : ${state?.storeCode}");
      subscribeToStoreWaitingInfo(state!.storeCode);
      sendStoreCode(state!.storeCode);
    } else {
      printd("reconnectByState : state is null");
    }
  }

  @override
  void dispose() {
    unSubscribe();
    super.dispose();
  }
}
