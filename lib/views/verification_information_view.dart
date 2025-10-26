import 'dart:typed_data';

import 'package:extract_information_student_card_app/services/snackbar_service.dart';
import 'package:extract_information_student_card_app/utils/image_utils.dart';
import 'package:extract_information_student_card_app/viewmodels/camera_viewmodel.dart';
import 'package:extract_information_student_card_app/viewmodels/verification_information_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VerificationInformationView extends StatefulWidget {
  final String imagePath;

  const VerificationInformationView({super.key, required this.imagePath});

  @override
  State<VerificationInformationView> createState() =>
      _VerificationInformationViewState();
}

class _VerificationInformationViewState
    extends State<VerificationInformationView> {
  late final TextEditingController _hoTenController;
  late final TextEditingController _mssvController;
  late final TextEditingController _ngaySinhController;
  late final TextEditingController _lopController;
  late final TextEditingController _khoaHocController;

  @override
  void initState() {
    super.initState();
    _hoTenController = TextEditingController();
    _mssvController = TextEditingController();
    _ngaySinhController = TextEditingController();
    _lopController = TextEditingController();
    _khoaHocController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _extractInformation();
    });
  }

  @override
  void dispose() {
    _hoTenController.dispose();
    _mssvController.dispose();
    _ngaySinhController.dispose();
    _lopController.dispose();
    _khoaHocController.dispose();
    super.dispose();
  }

  Future<void> _extractInformation() async {
    final viewModel = Provider.of<VerificationInformationViewModel>(
      context,
      listen: false,
    );
    await viewModel.extractInformation(widget.imagePath);
    _hoTenController.text = viewModel.studentInformation?.fullName ?? '';
    _mssvController.text = viewModel.studentInformation?.studentId ?? '';
    _ngaySinhController.text = viewModel.studentInformation?.dateOfBirth ?? '';
    _lopController.text = viewModel.studentInformation?.className ?? '';
    _khoaHocController.text = viewModel.studentInformation?.year ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VerificationInformationViewModel>(
      builder: (context, viewModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.errorMessage != null) {
            SnackbarService.showError(context, viewModel.errorMessage!);
            viewModel.clearError();
          }
        });

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, result) {
            if (didPop) {
              return;
            }
            while (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Thông tin xác minh'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  while (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                tooltip: 'Quay lại',
              ),
            ),
            body:
                viewModel.isProcessing || !viewModel.isInitialized
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Vui lòng kiểm tra và chỉnh sửa nếu có sai sót',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              clipBehavior:
                                  Clip.antiAlias, // Để bo góc cho ảnh con
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 250,
                                ),
                                child: FutureBuilder(
                                  future: ImageUtils.loadImageFromLocalPath(
                                    widget.imagePath,
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data as Uint8List,
                                          fit: BoxFit.contain,
                                        );
                                      } else {
                                        return const Center(
                                          child: Text('Lỗi khi tải ảnh'),
                                        );
                                      }
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildTextField(
                              controller: _hoTenController,
                              label: 'Họ và tên',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _mssvController,
                              label: 'Mã số sinh viên',
                              icon: Icons.badge_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _ngaySinhController,
                              label: 'Ngày sinh',
                              icon: Icons.calendar_today_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _lopController,
                              label: 'Lớp',
                              icon: Icons.school_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _khoaHocController,
                              label: 'Khóa học',
                              icon: Icons.date_range_outlined,
                            ),
                            const SizedBox(height: 16),
                            // Expanded(
                            //   child: ElevatedButton.icon(
                            //     icon: const Icon(Icons.check_circle_outline),
                            //     label: const Text('Xác nhận'),
                            //     onPressed: () {
                            //       // Gom dữ liệu đã chỉnh sửa vào một Map mới
                            //       // final updatedData = {
                            //       //   'ho_ten': _hoTenController.text.trim(),
                            //       //   'mssv': _mssvController.text.trim(),
                            //       //   'ngay_sinh': _ngaySinhController.text.trim(),
                            //       //   'lop': _lopController.text.trim(),
                            //       //   'khoa_hoc': _khoaHocController.text.trim(),
                            //       // };
                            //       // Trả về Map dữ liệu này
                            //       // Navigator.of(context).pop(updatedData);
                            //     },
                            //     style: ElevatedButton.styleFrom(
                            //       padding: const EdgeInsets.symmetric(
                            //         vertical: 14,
                            //       ),
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(12),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
