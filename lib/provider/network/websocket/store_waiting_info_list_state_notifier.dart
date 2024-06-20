import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_web/services/debug_services.dart';
import 'package:orre_web/model/store_waiting_info_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

final storeWaitingInfoListNotifierProvider =
    StateNotifierProvider<StoreWaitingInfoListNotifier, List<StoreWaitingInfo>>(
        (ref) {
  return StoreWaitingInfoListNotifier([]);
});

class StoreWaitingInfoListNotifier
    extends StateNotifier<List<StoreWaitingInfo>> {
  StompClient? _client;
  Map<int, dynamic> _subscriptions = {};

  StoreWaitingInfoListNotifier(super.initialState);

  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient client) {
    printd("StoreWaitingInfoList : setClient");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
  }

  void subscribeToStoreWaitingInfo(int storeCode) {
    if (_subscriptions[storeCode] == null) {
      printd("subscribedStoreCodes : $storeCode");
      printd("getWaitingTeamsList : ${getWaitingTeamsList(storeCode)}");
      _subscriptions[storeCode] = _client?.subscribe(
        destination: dotenv
                .get('ORRE_WEBSOCKET_ENDPOINT_STOREWAITINGINFOLIST_SUBSCRIBE') +
            storeCode.toString(),
        callback: (frame) {
          if (frame.body != null) {
            printd("subscribeToStoreWaitingInfo : ${frame.body}");
            var decodedBody = json.decode(frame.body!); // JSON 문자열을 객체로 변환
            if (decodedBody is Map<String, dynamic>) {
              // 첫 번째 요소를 추출하고 StoreWaitingInfo 인스턴스로 변환
              var firstResult = StoreWaitingInfo.fromJson(decodedBody);

              // 이미 있는 storeCode인 경우, 해당 요소의 내용을 업데이트
              var existingIndex = state.indexWhere(
                  (info) => info.storeCode == firstResult.storeCode);
              if (existingIndex != -1) {
                state[existingIndex] = firstResult;
                state = List.from(state);
                // saveState();
              } else {
                // 새로운 요소를 상태에 추가
                state = [...state, firstResult];
                // saveState();
              }
            }
            // printd("state : $state");
          }
        },
      );
      // printd("StoreWaitingInfoList/${storeCode} : subscribe!");
      sendStoreCode(storeCode);
    } else {
      // printd("StoreWaitingInfoList/${storeCode} : already subscribed!");
    }
  }

  // 사용자의 위치 정보를 서버로 전송하는 메소드
  void sendStoreCode(int storeCode) {
    printd("sendStoreCode : $storeCode");
    _client?.send(
      destination:
          dotenv.get('ORRE_WEBSOCKET_ENDPOINT_STOREWAITINGINFOLIST_REQUEST') +
              storeCode.toString(),
      body: json.encode({"storeCode": storeCode}),
    );
  }

  void unSubscribeAll() {
    printd("unSubscribeAll");
    _subscriptions.forEach((storeCode, unsubscribeFn) {
      unsubscribeFn();
      printd("unSubscribeAll/$storeCode : unsubscribe!");
    });
    // 모든 구독을 해제한 후, 구독 목록을 초기화
    _subscriptions.clear();

    printd("subscribedsubscriptionsStoreCodes : $_subscriptions");
  }

  List<int> getWaitingTeamsList(int storeCode) {
    final storeWaitingInfo =
        state.firstWhere((info) => info.storeCode == storeCode,
            orElse: () => StoreWaitingInfo(
                  storeCode: 0,
                  waitingTeamList: const [],
                  enteringTeamList: const [],
                  estimatedWaitingTimePerTeam: 0,
                ));
    return storeWaitingInfo.waitingTeamList;
  }

  void clearWaitingInfoList() {
    state = [];
    // saveState();
  }

  void saveState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<StoreWaitingInfo> storeWaitingInfoList = state;
    String encodedList = json.encode(storeWaitingInfoList);
    // printd("waitingInfoList saveState encodedList : $encodedList");
    prefs.setString('waitingInfoList', encodedList);
  }

  void loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encodedList = prefs.getString('waitingInfoList');
    if (encodedList != null) {
      printd("waitingInfoList loadState encodedList : $encodedList");
      List<dynamic> decodedList = json.decode(encodedList);
      state = decodedList
          .map((e) => StoreWaitingInfo.fromJson(e))
          .toList(); // JSON 문자열을 객체로 변환
      // saveState();
    }
  }

  void reconnect() {
    _client?.activate();
    loadState();
    for (var element in state) {
      printd("reconnect : ${element.storeCode}");
      subscribeToStoreWaitingInfo(element.storeCode);
    }
  }

  @override
  void dispose() {
    unSubscribeAll();
    super.dispose();
  }
}
