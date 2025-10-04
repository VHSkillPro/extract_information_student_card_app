import 'package:flutter/services.dart';

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
}
