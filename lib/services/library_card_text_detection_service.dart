import 'dart:ffi';
import 'dart:typed_data';
import 'package:extract_information_student_card_app/core/ffi/det_ffi.dart';
import 'package:extract_information_student_card_app/utils/file_utils.dart';
import 'package:extract_information_student_card_app/utils/image_utils.dart';
import 'package:logger/logger.dart';
import 'package:ffi/ffi.dart';

class LibraryCardTextDetectionService {
  // Singleton pattern
  static final LibraryCardTextDetectionService _instance =
      LibraryCardTextDetectionService._internal();

  factory LibraryCardTextDetectionService() {
    return _instance;
  }

  LibraryCardTextDetectionService._internal();

  // Configuration constants
  static const String _detModelPath =
      "assets/weights/ch_PP-OCRv3_det_slim_opt.nb";
  static const String runtimeDevice = "arm8";
  static const String precision = "INT8";
  static const int numThreads = 10;
  static const int batchSize = 1;
  static const String configPath = "assets/weights/config.txt";

  late Pointer<Utf8> _detModelPathPtr;
  late Pointer<Utf8> _runtimeDevicePtr;
  late Pointer<Utf8> _precisionPtr;
  late Pointer<Utf8> _configPathPtr;

  final Logger logger = Logger();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    logger.d("[LibraryCardTextDetectionService] 🔧 Loading model...");

    _detModelPathPtr =
        (await FileUtils.copyAssetToFile(
          _detModelPath,
          "ch_PP-OCRv3_det_slim_opt.nb",
        )).toNativeUtf8();
    _runtimeDevicePtr = runtimeDevice.toNativeUtf8();
    _precisionPtr = precision.toNativeUtf8();
    _configPathPtr =
        (await FileUtils.copyAssetToFile(
          configPath,
          "config.txt",
        )).toNativeUtf8();
    _initialized = true;

    logger.d('[LibraryCardTextDetectionService] ✅ Model loaded successfully!');
  }

  /// Detects text from the given image bytes using a native detection model.
  ///
  /// Throws an [Exception] if the service has not been initialized.
  ///
  /// Writes the provided [imageBytes] to a temporary file, then runs the native
  /// detection function with the configured model, device, precision, thread count,
  /// batch size, and configuration path.
  ///
  /// Frees any allocated native memory after detection.
  ///
  /// Returns a [DetResultList] containing the detection results.
  ///
  /// [imageBytes]: The image data as a [Uint8List] to be processed.
  Future<DetResultList> detect(Uint8List imageBytes) async {
    if (!_initialized) {
      throw Exception('LibraryCardTextDetectionService not initialized!');
    }

    final imageFilename = "temp_image.png";
    final imageFile = await ImageUtils.writeImageBytesToTempFile(
      imageFilename,
      imageBytes,
    );
    final imagePathPtr = imageFile.path.toNativeUtf8();

    final result = nativeRunDet(
      _detModelPathPtr,
      _runtimeDevicePtr,
      _precisionPtr,
      numThreads,
      batchSize,
      imagePathPtr,
      _configPathPtr,
    );

    malloc.free(imagePathPtr);
    return result;
  }

  /// Frees the memory allocated for the given [DetResultList].
  ///
  /// This method should be called after processing the detection results
  /// to prevent memory leaks by releasing any resources associated with [resultList].
  ///
  /// [resultList] - The detection result list to be freed.
  void freeResult(DetResultList resultList) {
    freeDetResult(resultList);
  }

  /// Releases allocated resources and frees memory pointers if the service has been initialized.
  ///
  /// This method should be called when the service is no longer needed to prevent memory leaks.
  /// It frees the memory allocated for model path, runtime device, precision, and config path pointers,
  /// and marks the service as uninitialized.
  void dispose() {
    if (_initialized) {
      malloc.free(_detModelPathPtr);
      malloc.free(_runtimeDevicePtr);
      malloc.free(_precisionPtr);
      malloc.free(_configPathPtr);
      _initialized = false;
    }
  }
}
