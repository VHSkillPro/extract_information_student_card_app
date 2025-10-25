import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:extract_information_student_card_app/services/snackbar_service.dart';
import 'package:extract_information_student_card_app/viewmodels/home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          // Show error snackbar when view build completes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.errorMessage != null) {
              SnackbarService.showError(context, viewModel.errorMessage!);
              viewModel.clearErrorMessage();
            }
          });

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SvgPicture.asset('assets/images/logo_husc.svg', width: 150),
                  const SizedBox(height: 64),
                  const Text(
                    'Ứng dụng trích xuất thông tin thẻ sinh viên',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ứng dụng PoC trích xuất thông tin từ thẻ sinh viên của trường Đại học Khoa học - Đại học Huế',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 72),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.startScan(context),
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label:
                        viewModel.isBusy
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              'BẮT ĐẦU QUÉT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => viewModel.pickFromGallery(context),
                    child:
                        viewModel.isBusy
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text(
                              'Chọn ảnh từ thư viện',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
