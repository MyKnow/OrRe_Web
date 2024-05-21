import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';

// StateNotifier to manage the camera list
class CameraNotifier extends StateNotifier<List<CameraDescription>> {
  CameraNotifier() : super([]);

  // Initialize the cameras and update the state
  Future<void> initializeCameras() async {
    final cameras = await availableCameras();
    state = cameras;
  }
}

// StateNotifierProvider to provide access to the CameraNotifier
final cameraProvider =
    StateNotifierProvider<CameraNotifier, List<CameraDescription>>((ref) {
  return CameraNotifier();
});
