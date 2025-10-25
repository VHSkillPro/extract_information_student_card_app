import 'dart:ffi';
import 'dart:typed_data';

import 'package:extract_information_student_card_app/core/ffi/det_ffi.dart';
import 'package:extract_information_student_card_app/services/card_classification_service.dart';
import 'package:extract_information_student_card_app/services/library_card_text_detection_service.dart';
import 'package:extract_information_student_card_app/services/student_card_text_detection_service.dart';
import 'package:extract_information_student_card_app/services/text_recognition_service.dart';
import 'package:extract_information_student_card_app/utils/image_utils.dart';
import 'package:extract_information_student_card_app/utils/types.dart';
import 'package:flutter/material.dart';

class VerificationInformationViewModel extends ChangeNotifier {
  CardClassificationService? _cardClassificationService;
  LibraryCardTextDetectionService? _libraryCardTextDetectionService;
  StudentCardTextDetectionService? _studentCardTextDetectionService;
  TextRecognitionService? _textRecognitionService;

  String? _studentId;
  String? _fullName;
  String? _dateOfBirth;
  String? _className;
  String? _semester;

  bool _isInitialized = false;
  bool _isProcessing = false;
  String? _errorMessage;

  String? get studentId => _studentId;
  String? get fullName => _fullName;
  String? get dateOfBirth => _dateOfBirth;
  String? get className => _className;
  String? get semester => _semester;

  bool get isInitialized => _isInitialized;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

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

  Future<void> disposeModel() async {
    _cardClassificationService = null;
    _libraryCardTextDetectionService?.dispose();
    _studentCardTextDetectionService?.dispose();
    _textRecognitionService?.dispose();
  }

  Future<void> extractInformation(String imagePath) async {
    if (!_isInitialized) {
      await initializeModel();
    }

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    Uint8List image;
    try {
      image = await ImageUtils.loadImageFromLocalPath(imagePath);
    } catch (e) {
      _errorMessage = 'Lỗi khi tải ảnh: $e';
      _isProcessing = false;
      notifyListeners();
      return;
    }

    if (_cardClassificationService == null) {
      _errorMessage = 'Dịch vụ phân loại thẻ chưa được khởi tạo.';
      _isProcessing = false;
      notifyListeners();
      return;
    }

    final cardType = await _cardClassificationService!.classify(image);

    if (cardType == CardType.library) {
      if (_libraryCardTextDetectionService == null) {
        _errorMessage =
            'Dịch vụ phát hiện văn bản thẻ thư viện chưa được khởi tạo.';
        _isProcessing = false;
        notifyListeners();
        return;
      }

      DetResultList detResultList = await _libraryCardTextDetectionService!
          .detect(image);

      for (int i = 0; i < detResultList.count; ++i) {
        DetResult detResult = detResultList.data[i];
        print(
          '${detResult.box[0]}, ${detResult.box[1]}, ${detResult.box[2]}, ${detResult.box[3]}, ${detResult.box[4]}, ${detResult.box[5]}, ${detResult.box[6]}, ${detResult.box[7]}',
        );
      }
      _libraryCardTextDetectionService!.freeResult(detResultList);
    } else {
      if (_studentCardTextDetectionService == null) {
        _errorMessage =
            'Dịch vụ phát hiện văn bản thẻ sinh viên chưa được khởi tạo.';
        _isProcessing = false;
        notifyListeners();
        return;
      }
      // final detectedRegions = await _studentCardTextDetectionService!.detect(
      //   image,
      // );
    }

    _isProcessing = false;
    notifyListeners();
  }
}
