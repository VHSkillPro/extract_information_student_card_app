import 'package:extract_information_student_card_app/viewmodels/edit_crop_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditCropView extends StatefulWidget {
  final String imagePath;

  const EditCropView({super.key, required this.imagePath});

  @override
  State<EditCropView> createState() => _EditCropViewState();
}

class _EditCropViewState extends State<EditCropView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCrop();
    });
  }

  Future<void> _startCrop() async {
    final viewModel = Provider.of<EditCropViewModel>(context, listen: false);
    final croppedImagePath = await viewModel.cropImage(widget.imagePath);

    if (!mounted) return;

    if (croppedImagePath != null) {
      viewModel.proceedToVerification(context, croppedImagePath);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Đang chuẩn bị trình cắt ảnh...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
