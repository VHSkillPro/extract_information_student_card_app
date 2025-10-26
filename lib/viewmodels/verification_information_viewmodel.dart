import 'dart:ffi';
import 'dart:typed_data';
import 'package:extract_information_student_card_app/models/student_information.dart';
import 'package:flutter/material.dart';
import 'package:extract_information_student_card_app/core/ffi/det_ffi.dart';
import 'package:extract_information_student_card_app/models/bbox.dart';
import 'package:extract_information_student_card_app/services/card_classification_service.dart';
import 'package:extract_information_student_card_app/services/library_card_text_detection_service.dart';
import 'package:extract_information_student_card_app/services/student_card_text_detection_service.dart';
import 'package:extract_information_student_card_app/services/text_recognition_service.dart';
import 'package:extract_information_student_card_app/utils/image_utils.dart';
import 'package:extract_information_student_card_app/utils/types.dart';

class VerificationInformationViewModel extends ChangeNotifier {
  CardClassificationService? _cardClassificationService;
  LibraryCardTextDetectionService? _libraryCardTextDetectionService;
  StudentCardTextDetectionService? _studentCardTextDetectionService;
  TextRecognitionService? _textRecognitionService;

  bool _isInitialized = false;
  bool _isProcessing = false;
  String? _errorMessage;
  StudentInformation? _studentInformation;

  bool get isInitialized => _isInitialized;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  StudentInformation? get studentInformation => _studentInformation;

  Future<void> initializeModel() async {
    _cardClassificationService = CardClassificationService();
    await _cardClassificationService!.initialize();

    _libraryCardTextDetectionService = LibraryCardTextDetectionService();
    await _libraryCardTextDetectionService!.initialize();

    _studentCardTextDetectionService = StudentCardTextDetectionService();
    await _studentCardTextDetectionService!.initialize();

    _textRecognitionService = TextRecognitionService();
    await _textRecognitionService!.initialize();

    _isInitialized = true;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> extractInformation(String imagePath) async {
    if (!_isInitialized) {
      await initializeModel();
    }

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    _studentInformation = StudentInformation(
      fullName: "Ngô Văn Hải",
      studentId: "21T1020340",
      dateOfBirth: "09/09/2003",
      className: "Công nghệ thông tin K45F",
      year: "2021 - 2025",
    );

    // Uint8List image;
    // try {
    //   image = await ImageUtils.loadImageFromLocalPath(imagePath);
    // } catch (e) {
    //   _errorMessage = 'Lỗi khi tải ảnh: $e';
    //   _isProcessing = false;
    //   notifyListeners();
    //   return;
    // }

    // final cardType = await _cardClassificationService!.classify(image);

    // List<Bbox> bboxs = [];
    // if (cardType == CardType.library) {
    //   DetResultList detResultList = await _libraryCardTextDetectionService!
    //       .detect(image);

    //   for (int i = 0; i < detResultList.count; ++i) {
    //     DetResult detResult = detResultList.data[i];
    //     Bbox bbox = Bbox(
    //       xMin: detResult.box[0],
    //       yMin: detResult.box[1],
    //       xMax: detResult.box[4],
    //       yMax: detResult.box[5],
    //     );

    //     try {
    //       final croppedImage = await ImageUtils.cropImageFromBbox(image, bbox);
    //       final label = await _textRecognitionService!.recognize(croppedImage);
    //       bbox.label = label;
    //       bboxs.add(bbox);
    //     } catch (e) {
    //       _errorMessage = 'Lỗi khi cắt ảnh: $e';
    //       _isProcessing = false;
    //       notifyListeners();
    //       return;
    //     }
    //   }
    //   _libraryCardTextDetectionService!.freeResult(detResultList);
    // } else {
    //   // final detectedRegions = await _studentCardTextDetectionService!.detect(
    //   //   image,
    //   // );
    // }

    _isProcessing = false;
    notifyListeners();
  }
}
