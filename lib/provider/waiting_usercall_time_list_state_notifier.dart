import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_web/provider/network/websocket/store_waiting_info_request_state_notifier.dart';

class WaitingUserCallTimeListStateNotifier extends StateNotifier<Duration?> {
  DateTime? userCallTime;
  Timer? timer;
  late Ref ref;

  WaitingUserCallTimeListStateNotifier(this.ref) : super(null);

  // Sets the user call time and starts a timer to update the remaining time
  void setUserCallTime(DateTime userCallTime) {
    if (userCallTime.isBefore(DateTime.now().toUtc())) {
      print("유저 호출 시간이 현재 시간보다 이전입니다.");
      deleteTimer();
      return;
    } else {
      print("유저 호출 시간이 현재 시간보다 이후입니다.");
    }
    this.userCallTime = userCallTime;
    startTimer();
  }

  // Starts a periodic timer that updates the time difference
  void startTimer() {
    // Cancel any existing timer before starting a new one
    timer?.cancel();

    timer = Timer.periodic(Duration(seconds: 1), (_) {
      updateDifference();
    });
  }

  // Updates the remaining time and cancels the timer if the time is up
  void updateDifference() {
    if (userCallTime == null) {
      deleteTimer();
      return;
    }
    final currentTime = DateTime.now().toUtc();

    // Convert userCallTime to local time
    final localUserCallTime = userCallTime!.toLocal();

    print("유저 호출 시간 (로컬): $localUserCallTime");
    print("현재 시간: $currentTime");

    if (currentTime.isAfter(localUserCallTime)) {
      print("유저 호출 시간이 지났습니다.");
      deleteTimer();
      return;
    } else {
      print("유저 호출 시간이 지나지 않았습니다.");
    }
  }

  // Stops the timer and cleans up
  void deleteTimer() {
    print('Stopping and deleting timer');
    timer?.cancel();
    timer = null;
    state = null; // Optionally reset state to null when the timer is stopped
    ref
        .read(storeWaitingRequestNotifierProvider.notifier)
        .clearWaitingRequestList();
  }

  // Disposes of the state notifier and its resources
  @override
  void dispose() {
    print('Disposing WaitingUserCallTimeListStateNotifier');
    deleteTimer();
    super.dispose();
  }
}

final waitingUserCallTimeListProvider =
    StateNotifierProvider<WaitingUserCallTimeListStateNotifier, Duration?>(
  (ref) => WaitingUserCallTimeListStateNotifier(ref),
);
