import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:extract_information_student_card_app/views/camera_view.dart';

class HomeViewModel extends ChangeNotifier {
  bool _isBusy = false;
  bool get isBusy => _isBusy;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
  }

  void startScan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraView()),
    );
  }

  Future<XFile?> pickFromGallery(BuildContext context) async {
    if (_isBusy) return null;

    XFile? pickedFile;

    try {
      _isBusy = true;
      notifyListeners();

      final ImagePicker picker = ImagePicker();
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
      return pickedFile;
    } catch (e) {
      _errorMessage =
          'Không thể mở thư viện ảnh. Vui lòng kiểm tra lại quyền truy cập.';
      notifyListeners();
      return null;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
