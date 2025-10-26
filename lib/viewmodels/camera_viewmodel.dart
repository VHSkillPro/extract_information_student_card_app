import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:extract_information_student_card_app/views/edit_crop_view.dart';

class CameraViewModel extends ChangeNotifier {
  bool _isBusy = false;
  String? _errorMessage;
  bool _isInitialized = false;
  CameraController? _controller;
  FlashMode _flashMode = FlashMode.off;

  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  CameraController? get controller => _controller;
  FlashMode get flashMode => _flashMode;

  /// Initializes the camera for capturing images.
  Future<void> initializeCamera() async {
    cleanUpCamera();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        _isInitialized = false;
        _errorMessage = 'Không tìm thấy camera trên thiết bị.';
        notifyListeners();
        return;
      }

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
      _errorMessage = 'Không thể khởi tạo camera: ${e.toString()}';
    }

    notifyListeners();
  }

  /// Disposes the camera controller and resets the camera's initialized state.
  void cleanUpCamera() {
    if (!_isInitialized) return;
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    notifyListeners();
  }

  /// Clears the current error message.
  void clearErrorMessage() {
    _errorMessage = null;
  }

  /// Toggles the camera's flash mode.
  Future<void> toggleFlash() async {
    try {
      _flashMode =
          _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
      if (_controller != null) {
        await _controller!.setFlashMode(_flashMode);
      } else {
        _errorMessage = "Camera chưa được khởi tạo.";
      }
    } catch (e) {
      _errorMessage =
          "Đã xảy ra lỗi khi thay đổi chế độ đèn flash: ${e.toString()}";
    }
    notifyListeners();
  }

  /// Captures an image using the device's camera.
  Future<void> takePicture(BuildContext context) async {
    if (_isBusy) return;

    if (!_isInitialized) {
      _errorMessage = 'Camera chưa được khởi tạo.';
      notifyListeners();
      return;
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      _errorMessage = 'Camera chưa sẵn sàng.';
      notifyListeners();
      return;
    }

    _isBusy = true;
    notifyListeners();

    try {
      XFile? imageFile = await _controller!.takePicture();
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => EditCropView(
                  imagePath: imageFile.path,
                  isFromGallery: false,
                ),
          ),
        );
        cleanUpCamera();
      } else {
        _errorMessage = 'Không thể điều hướng: ngữ cảnh không còn hợp lệ.';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi khi chụp ảnh: ${e.toString()}';
      notifyListeners();
    }

    _isBusy = false;
    notifyListeners();
  }
}
