import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraViewModel extends ChangeNotifier {
  bool _isBusy = false;
  XFile? _capturedImage;
  String? _errorMessage;
  bool _isInitialized = false;
  CameraController? _controller;
  FlashMode _flashMode = FlashMode.off;

  bool get isBusy => _isBusy;
  XFile? get capturedImage => _capturedImage;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  CameraController? get controller => _controller;
  FlashMode get flashMode => _flashMode;

  Future<void> initializeCamera() async {
    cleanUpCamera();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    try {
      final cameras = await availableCameras();
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      _errorMessage =
          'Không thể khởi tạo camera. Vui lòng kiểm tra lại quyền truy cập.';
    }

    notifyListeners();
  }

  void cleanUpCamera() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  void clearError() {
    _errorMessage = null;
  }

  Future<void> toggleFlash() async {
    if (_controller == null) return;
    _flashMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await _controller!.setFlashMode(_flashMode);
    notifyListeners();
  }

  Future<XFile?> takePicture() async {
    if (_isBusy) return null;

    if (_controller == null || !_controller!.value.isInitialized) {
      _errorMessage = 'Camera chưa sẵn sàng.';
      notifyListeners();
      return null;
    }

    XFile? image;

    try {
      _isBusy = true;
      notifyListeners();

      image = await _controller!.takePicture();
      return image;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi khi chụp ảnh. Vui lòng thử lại.';
      notifyListeners();
      return null;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
