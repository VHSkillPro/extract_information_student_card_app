import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:extract_information_student_card_app/models/bbox.dart';

class ImageUtils {
  /// Loads an image from the specified asset [path] and returns its bytes as a [Uint8List].
  ///
  /// This method asynchronously reads the image file from the application's asset bundle.
  ///
  /// [path]: The relative path to the asset image.
  ///
  /// Returns a [Future] that completes with the image data as a [Uint8List].
  ///
  /// Throws a [FlutterError] if the asset cannot be found or loaded.
  static Future<Uint8List> loadImageFromAssets(String path) async {
    final byteData = await rootBundle.load(path);
    return byteData.buffer.asUint8List();
  }

  static Future<Uint8List> loadImageFromLocalPath(String path) async {
    try {
      File imageFile = File(path);
      if (await imageFile.exists()) {
        Uint8List imageBytes = await imageFile.readAsBytes();
        return imageBytes;
      } else {
        throw Exception("File không tồn tại tại đường dẫn: $path");
      }
    } catch (e) {
      throw Exception("Lỗi khi đọc file ảnh: $e");
    }
  }

  /// Writes the provided [imageBytes] to a temporary file with the given [filename].
  ///
  /// The file is created in the system's temporary directory.
  ///
  /// Returns a [File] pointing to the newly created file.
  ///
  /// [filename]: The name to use for the temporary file.
  /// [imageBytes]: The image data to write to the file.
  ///
  /// Throws an [IOException] if writing fails.
  static Future<File> writeImageBytesToTempFile(
    String filename,
    Uint8List imageBytes,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$filename');
    await tempFile.writeAsBytes(imageBytes);
    return tempFile;
  }

  /// Crops an image from a [Uint8List] using the coordinates from a [Bbox].
  ///
  /// This function decodes the [originalImageBytes] into an image, then uses the
  /// `xMin`, `yMin`, `xMax`, and `yMax` properties of the [bbox] to define a
  /// rectangular area to crop. The resulting cropped image is encoded as a PNG
  /// and returned as a `Uint8List`.
  ///
  /// - [originalImageBytes]: The byte data of the original image to be cropped.
  /// - [bbox]: The bounding box object that specifies the crop area.
  ///
  /// Returns a [Future] that completes with the `Uint8List` of the cropped image
  /// in PNG format.
  ///
  /// Throws an [Exception] if the original image cannot be decoded or if any
  /// other error occurs during the cropping process.
  static Future<Uint8List> cropImageFromBbox(
    Uint8List originalImageBytes,
    Bbox bbox,
  ) async {
    try {
      final img.Image? originalImage = img.decodeImage(originalImageBytes);

      if (originalImage == null) {
        throw Exception("Không thể giải mã ảnh gốc.");
      }

      final int x = bbox.xMin;
      final int y = bbox.yMin;
      final int width = bbox.xMax - bbox.xMin;
      final int height = bbox.yMax - bbox.yMin;

      final img.Image croppedImage = img.copyCrop(
        originalImage,
        x: x,
        y: y,
        width: width,
        height: height,
      );

      final Uint8List croppedBytes = img.encodePng(croppedImage);
      return croppedBytes;
    } catch (e) {
      throw Exception("Lỗi khi cắt ảnh: $e");
    }
  }
}
