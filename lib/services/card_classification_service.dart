import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:extract_information_student_card_app/utils/types.dart';

class CardClassificationService {
  // Singleton pattern
  static final CardClassificationService _instance =
      CardClassificationService._internal();

  factory CardClassificationService() {
    return _instance;
  }

  CardClassificationService._internal();

  // ONNX Runtime variables
  static const int inputSize = 224;

  bool _initialized = false;
  OrtSession? _session;

  /// Initializes the card classification service by loading the ONNX model.
  ///
  /// This method checks if the service has already been initialized to prevent
  /// redundant loading. If not initialized, it loads the ONNX model from the
  /// assets, creates an ONNX runtime session, and marks the service as initialized.
  /// Logs are generated to indicate the loading process and its success.
  ///
  /// Throws an exception if the model fails to load.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    final sessionOptions = OrtSessionOptions();
    final rawModel = await rootBundle.load('assets/weights/classify.onnx');
    final bytes = rawModel.buffer.asUint8List();
    _session = OrtSession.fromBuffer(bytes, sessionOptions);
    _initialized = true;
    Logger().d('[CardClassificationService] Initialized successfully.');
  }

  /// Classifies the given image bytes as a card type.
  ///
  /// Throws an [Exception] if the service has not been initialized.
  ///
  /// The method preprocesses the input image, runs inference using the ONNX runtime session,
  /// and postprocesses the output to determine the card type.
  ///
  /// Returns a [CardType] indicating whether the card is a student card or a library card.
  ///
  /// [imageBytes]: The image data as a [Uint8List].
  Future<CardType> classify(Uint8List imageBytes) async {
    if (!_initialized) {
      throw Exception('CardClassificationService not initialized!');
    }

    // Preprocess the image
    final input = _preprocess(imageBytes);

    // Run inference
    final ortInput = OrtValueTensor.createTensorWithDataList(input, [
      1,
      inputSize,
      inputSize,
      3,
    ]);

    final outputs = _session!.run(OrtRunOptions(), {'input': ortInput});
    final output = outputs.first!.value as List<List<double>>;

    // Postprocess the output to determine card type
    CardType result =
        output[0][0] >= output[0][1] ? CardType.student : CardType.library;

    // Clean up
    ortInput.release();
    for (var element in outputs) {
      element!.release();
    }

    return result;
  }

  /// Preprocesses the input image bytes for model inference.
  ///
  /// Decodes the given [imageBytes] into an image, resizes it to [inputSize] x [inputSize],
  /// and converts the pixel data into a [Float32List] in RGB order.
  /// The output is a flattened list of float values representing the image,
  /// suitable for input into a machine learning model.
  ///
  /// Throws an error if the image cannot be decoded.
  ///
  /// - Parameter imageBytes: The raw bytes of the image to preprocess.
  /// - Returns: A [Float32List] containing the preprocessed image data.
  Float32List _preprocess(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes)!;
    final resized = img.copyResize(image, width: inputSize, height: inputSize);

    final input = Float32List(1 * inputSize * inputSize * 3);

    for (var y = 0, index = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);

        final r = pixel.getChannel(img.Channel.red).toDouble();
        final g = pixel.getChannel(img.Channel.green).toDouble();
        final b = pixel.getChannel(img.Channel.blue).toDouble();

        input[index++] = r;
        input[index++] = g;
        input[index++] = b;
      }
    }

    return input;
  }
}
