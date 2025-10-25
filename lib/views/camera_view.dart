import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:extract_information_student_card_app/views/edit_crop_view.dart';
import 'package:extract_information_student_card_app/services/snackbar_service.dart';
import 'package:extract_information_student_card_app/viewmodels/camera_viewmodel.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<CameraViewModel>(context, listen: false);
    _viewModel.initializeCamera();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraViewModel>(
      builder: (context, viewModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.errorMessage != null) {
            SnackbarService.showError(context, viewModel.errorMessage!);
            viewModel.clearError();
          }
        });

        if (!viewModel.isInitialized || viewModel.controller == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final size = MediaQuery.of(context).size;
        final cameraAspectRatio = viewModel.controller!.value.aspectRatio;
        var scale = size.aspectRatio * cameraAspectRatio;
        if (scale < 1) scale = 1 / scale;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              ClipRect(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: viewModel.controller!.value.previewSize!.height,
                    height: viewModel.controller!.value.previewSize!.width,
                    child: CameraPreview(viewModel.controller!),
                  ),
                ),
              ),
              _buildGuidanceOverlay(),
              _buildControlBar(context, viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuidanceOverlay() {
    final size = MediaQuery.of(context).size;
    const cardAspectRatio = 1.25;
    final frameWidth = size.width * 0.9;
    final frameHeight = frameWidth / cardAspectRatio;

    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withAlpha(150),
        BlendMode.srcOut,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              backgroundBlendMode: BlendMode.dstOut,
            ),
          ),
          Center(
            child: Container(
              width: frameWidth,
              height: frameHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, CameraViewModel viewModel) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black.withAlpha(150),
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () => viewModel.toggleFlash(),
              icon: Icon(
                viewModel.flashMode == FlashMode.torch
                    ? Icons.flash_on
                    : Icons.flash_off,
                color: Colors.white,
                size: 30,
              ),
            ),
            GestureDetector(
              onTap: () async {
                final imageFile = await viewModel.takePicture();
                if (imageFile == null || !mounted) {
                  SnackbarService.showError(
                    context,
                    "Chụp ảnh thất bại. Vui lòng thử lại.",
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditCropView(imagePath: imageFile.path),
                  ),
                );
              },
              child: Opacity(
                opacity: viewModel.isBusy ? 0.5 : 1.0,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400, width: 4),
                  ),
                  child:
                      viewModel.isBusy
                          ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.blue,
                            ),
                          )
                          : null,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
