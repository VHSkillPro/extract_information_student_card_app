import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class EditCropViewModel extends ChangeNotifier {
  Future<String?> cropImage(String imagePath) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      // Tỷ lệ khung hình cho thẻ sinh viên (tương đương thẻ ATM, CCCD)
      aspectRatio: const CropAspectRatio(ratioX: 85.6, ratioY: 53.98),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cắt & Căn chỉnh Thẻ',
          toolbarColor: const Color(0xFF0D47A1), // Màu xanh đậm
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false, // Cho phép người dùng thay đổi tỷ lệ
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
    // TODO: Điều hướng đến màn hình VerificationView và truyền đường dẫn ảnh đã cắt
    print(
      'Đã cắt xong, chuyển đến màn hình xác nhận với ảnh: $croppedImagePath',
    );
    // Ví dụ:
    // Navigator.push(context, MaterialPageRoute(builder: (context) => VerificationView(imagePath: croppedImagePath)));

    // Tạm thời chúng ta sẽ pop 2 lần để quay về màn hình chính
    Navigator.of(context)
      ..pop()
      ..pop();
  }
}
