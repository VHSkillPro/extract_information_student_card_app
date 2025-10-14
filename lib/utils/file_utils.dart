import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  /// Copies an asset from the application's bundle to a temporary file.
  ///
  /// Loads the asset specified by [assetPath], writes its contents to a file named [filename]
  /// in the temporary directory, and returns the path to the newly created file.
  ///
  /// Returns a [Future] that completes with the path to the copied file.
  ///
  /// Throws an [Exception] if the asset cannot be loaded or the file cannot be written.
  static Future<String> copyAssetToFile(
    String assetPath,
    String filename,
  ) async {
    final byteData = await rootBundle.load(assetPath);
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/$filename");
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }
}
