import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:extract_information_student_card_app/views/camera_view.dart';
import 'package:extract_information_student_card_app/views/edit_crop_view.dart';

class HomeViewModel extends ChangeNotifier {
  bool _isBusy = false;
  String? _errorMessage;

  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;

  /// Clears the current error message by setting it to null.
  void clearErrorMessage() {
    _errorMessage = null;
  }

  /// Navigates to the camera screen to begin a scanning flow.
  ///
  /// The [context] is used to obtain the Navigator for pushing the route.
  void startScan(BuildContext context) {
    if (_isBusy) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraView()),
    );
  }

  /// Picks an image from the device's gallery and navigates to the cropping view.
  ///
  /// The [context] is used for navigation.
  Future<void> pickFromGallery(BuildContext context) async {
    if (_isBusy) {
      return;
    }

    _isBusy = true;
    notifyListeners();

    try {
      final ImagePicker picker = ImagePicker();
      XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditCropView(imagePath: pickedFile.path),
          ),
        );
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi chọn ảnh từ thư viện: $e';
      notifyListeners();
    }

    _isBusy = false;
    notifyListeners();
  }
}
