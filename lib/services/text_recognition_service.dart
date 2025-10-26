import 'dart:ffi';
import 'dart:typed_data';
import 'package:extract_information_student_card_app/core/ffi/reg_ffi.dart';
import 'package:extract_information_student_card_app/utils/file_utils.dart';
import 'package:extract_information_student_card_app/utils/image_utils.dart';
import 'package:ffi/ffi.dart';
import 'package:logger/logger.dart';

class TextRecognitionService {
  // Singleton pattern
  static final TextRecognitionService _instance =
      TextRecognitionService._internal();

  factory TextRecognitionService() {
    return _instance;
  }

  TextRecognitionService._internal();

  // Service
  static const String _modelDir = "assets/weights/recognition";

  bool _initialized = false;
  late Pointer<Utf8> _modelDirPtr;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await FileUtils.copyAssetToFile("$_modelDir/cnn.onnx", "cnn.onnx");
    await FileUtils.copyAssetToFile("$_modelDir/decoder.onnx", "decoder.onnx");
    final path = await FileUtils.copyAssetToFile(
      "$_modelDir/encoder.onnx",
      "encoder.onnx",
    );

    _modelDirPtr = path.substring(0, path.lastIndexOf('/')).toNativeUtf8();
    _initialized = true;

    Logger().d('[TextRecognitionService] Initialized successfully.');
  }

  Future<String> recognize(Uint8List imageBytes) async {
    if (!_initialized) {
      throw Exception("[TextRecognitionService] Service not initialized.");
    }

    final imageFilename = "temp_image_rec.png";
    final imageFile = await ImageUtils.writeImageBytesToTempFile(
      imageFilename,
      imageBytes,
    );
    final imagePathPtr = imageFile.path.toNativeUtf8();

    final result = nativeRunReg(_modelDirPtr, imagePathPtr);
    final recognizedText = result.toDartString();
    nativeFreeUtf8String(result);

    malloc.free(imagePathPtr);
    return recognizedText;
  }
}
