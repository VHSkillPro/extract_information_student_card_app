import 'package:extract_information_student_card_app/services/snackbar_service.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _extractInformation();
    });
  }

  Future<void> _extractInformation() async {
    final viewModel = Provider.of<VerificationInformationViewModel>(
      context,
      listen: false,
    );
    await viewModel.extractInformation(widget.imagePath);
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

        return Scaffold(
          appBar: AppBar(title: const Text('Thông tin xác minh')),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back),
          ),
          body:
              viewModel.isProcessing || !viewModel.isInitialized
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mã số sinh viên: ${viewModel.studentId ?? ''}'),
                        Text('Họ và tên: ${viewModel.fullName ?? ''}'),
                        Text('Ngày sinh: ${viewModel.dateOfBirth ?? ''}'),
                        Text('Lớp: ${viewModel.className ?? ''}'),
                        Text('Học kỳ: ${viewModel.semester ?? ''}'),
                      ],
                    ),
                  ),
        );
      },
    );
  }
}
