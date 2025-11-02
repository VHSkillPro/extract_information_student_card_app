import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';
import 'package:extract_information_student_card_app/models/bbox.dart';
import 'package:ffi/ffi.dart';
import 'package:logger/logger.dart';
import 'package:extract_information_student_card_app/core/ffi/det_ffi.dart';
import 'package:extract_information_student_card_app/utils/file_utils.dart';
import 'package:extract_information_student_card_app/utils/image_utils.dart';

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
      "assets/weights/detection/db_mv3_library.nb";
  static const String runtimeDevice = "arm8";
  static const String precision = "INT8";
  static const int numThreads = 10;
  static const int batchSize = 1;
  static const String configPath = "assets/weights/detection/config.txt";

  bool _initialized = false;
  late Pointer<Utf8> _detModelPathPtr;
  late Pointer<Utf8> _runtimeDevicePtr;
  late Pointer<Utf8> _precisionPtr;
  late Pointer<Utf8> _configPathPtr;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _detModelPathPtr =
        (await FileUtils.copyAssetToFile(
          _detModelPath,
          "db_mv3_library.nb",
        )).toNativeUtf8();
    _runtimeDevicePtr = runtimeDevice.toNativeUtf8();
    _precisionPtr = precision.toNativeUtf8();
    _configPathPtr =
        (await FileUtils.copyAssetToFile(
          configPath,
          "config.txt",
        )).toNativeUtf8();
    _initialized = true;

    Logger().d("[LibraryCardTextDetectionService] Initialized successfully.");
  }

  /// Detects text from the given image bytes using a native detection model.
  Future<List<Bbox>> detect(Uint8List imageBytes) async {
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

    List<Bbox> bboxList = [];
    for (int i = 0; i < result.count; ++i) {
      DetResult detResult = result.data[i];
      Bbox bbox = Bbox(
        xMin: min(
          min(detResult.box[0], detResult.box[2]),
          min(detResult.box[4], detResult.box[6]),
        ),
        yMin: min(
          min(detResult.box[1], detResult.box[3]),
          min(detResult.box[5], detResult.box[7]),
        ),
        xMax: max(
          max(detResult.box[0], detResult.box[2]),
          max(detResult.box[4], detResult.box[6]),
        ),
        yMax: max(
          max(detResult.box[1], detResult.box[3]),
          max(detResult.box[5], detResult.box[7]),
        ),
      );
      bboxList.add(bbox);
    }

    freeDetResult(result);
    return bboxList;
  }
}
