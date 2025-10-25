import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:extract_information_student_card_app/services/snackbar_service.dart';
import 'package:extract_information_student_card_app/viewmodels/camera_viewmodel.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraViewModel>(
      builder: (context, viewModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.errorMessage != null) {
            SnackbarService.showError(context, viewModel.errorMessage!);
            viewModel.clearErrorMessage();
          }
        });

        if (!viewModel.isInitialized) {
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
              _buildGuidanceOverlay(context),
              _buildControlBar(context, viewModel),
            ],
          ),
        );
      },
    );
  }

  /// Builds a semi-transparent overlay to guide the user in positioning their card.
  Widget _buildGuidanceOverlay(BuildContext context) {
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

  /// Builds the control bar widget for the camera view.
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
                await viewModel.takePicture(context);
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
              onPressed: () {
                Navigator.of(context).pop();
                viewModel.cleanUpCamera();
              },
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
