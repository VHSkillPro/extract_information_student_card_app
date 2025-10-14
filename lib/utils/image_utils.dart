import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

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
}
