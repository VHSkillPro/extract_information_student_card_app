import 'package:extract_information_student_card_app/views/verification_information_view.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class EditCropViewModel extends ChangeNotifier {
  Future<String?> cropImage(String imagePath) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatio: const CropAspectRatio(ratioX: 85.6, ratioY: 53.98),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cắt & Căn chỉnh Thẻ',
          toolbarColor: const Color(0xFF0D47A1),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cắt & Căn chỉnh Thẻ',
          doneButtonTitle: 'Xong',
          cancelButtonTitle: 'Hủy',
        ),
      ],
    );

    if (croppedFile != null) {
      return croppedFile.path;
    }
    return null;
  }

  void proceedToVerification(BuildContext context, String croppedImagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                VerificationInformationView(imagePath: croppedImagePath),
      ),
    );
  }
}
