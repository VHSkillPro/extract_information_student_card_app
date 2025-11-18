import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:extract_information_student_card_app/models/bbox.dart';
import 'package:extract_information_student_card_app/utils/types.dart';
import 'package:extract_information_student_card_app/utils/image_utils.dart';
import 'package:extract_information_student_card_app/models/student_information.dart';
import 'package:extract_information_student_card_app/services/text_recognition_service.dart';
import 'package:extract_information_student_card_app/services/card_classification_service.dart';
import 'package:extract_information_student_card_app/services/library_card_text_detection_service.dart';
import 'package:extract_information_student_card_app/services/student_card_text_detection_service.dart';

class VerificationInformationViewModel extends ChangeNotifier {
  CardClassificationService? _cardClassificationService;
  LibraryCardTextDetectionService? _libraryCardTextDetectionService;
  StudentCardTextDetectionService? _studentCardTextDetectionService;
  TextRecognitionService? _textRecognitionService;

  List<Bbox> _detectedBboxs = [];
  bool _isInitialized = false;
  bool _isProcessing = false;
  String? _errorMessage;
  StudentInformation? _studentInformation;

  List<Bbox> get detectedBboxs => _detectedBboxs;
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

    _detectedBboxs = [];
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    // Classify card
    Uint8List image;
    try {
      image = await ImageUtils.loadImageFromLocalPath(imagePath);
    } catch (e) {
      _errorMessage = 'Lỗi khi tải ảnh: $e';
      _isProcessing = false;
      notifyListeners();
      return;
    }
    final cardType = await _cardClassificationService!.classify(image);

    // Extract text regions
    if (cardType == CardType.library) {
      _detectedBboxs = await _libraryCardTextDetectionService!.detect(image);
    } else {
      _detectedBboxs = await _studentCardTextDetectionService!.detect(image);
    }

    // Recognize text from cropped images
    List<Uint8List> croppedImages = [];
    for (final bbox in _detectedBboxs) {
      try {
        final croppedImage = await ImageUtils.cropImageFromBbox(image, bbox);
        croppedImages.add(croppedImage);
      } catch (e) {
        _errorMessage = 'Lỗi khi cắt ảnh: $e';
        _isProcessing = false;
        notifyListeners();
        return;
      }
    }

    final labels = await _textRecognitionService!.recognizeBatch(croppedImages);
    for (int i = 0; i < _detectedBboxs.length; i++) {
      _detectedBboxs[i].label = labels[i];
      print(_detectedBboxs[i].toString());
    }

    _studentInformation = await _classifyInformationForLibraryCard(
      _detectedBboxs,
    );
    _isProcessing = false;
    notifyListeners();
  }

  Future<StudentInformation> _classifyInformationForLibraryCard(
    List<Bbox> labels,
  ) async {
    final Map<String, String> extractedData = {};

    List<Bbox> unclassified = List.from(labels);
    final Map<String, RegExp> fieldRegex = {
      'dateOfBirth': RegExp(r'^\d{2}/\d{2}/\d{4}$'),
      'year': RegExp(r'^\d{4}\s*-\s*\d{4}$'),
      'studentId': RegExp(r'^\d{2}[a-zA-Z]\d{5,8}$'),
    };

    Bbox? dobAnchor;
    Bbox? yearAnchor;

    unclassified.removeWhere((result) {
      if (result.label.trim().length < 2) {
        return true;
      }

      for (var entry in fieldRegex.entries) {
        String fieldName = entry.key;
        RegExp pattern = entry.value;

        if (pattern.hasMatch(result.label.trim()) &&
            !extractedData.containsKey(fieldName)) {
          extractedData[fieldName] = result.label.trim();
          if (fieldName == 'dateOfBirth') {
            dobAnchor = result;
          } else if (fieldName == 'year') {
            yearAnchor = result;
          }
          return true;
        }
      }
      return false;
    });

    unclassified.sort((a, b) => a.yMin.compareTo(b.yMin));

    if (dobAnchor != null) {
      Bbox? nameCandidate;
      double minVerticalDistance = double.infinity;

      for (final bbox in unclassified) {
        bool isAbove = bbox.yMax < dobAnchor!.yMin;
        if (isAbove) {
          double verticalDistance = double.parse(
            (dobAnchor!.yMin - bbox.yMax).toString(),
          );
          if (verticalDistance < minVerticalDistance) {
            minVerticalDistance = verticalDistance;
            nameCandidate = bbox;
          }
        }
      }

      if (nameCandidate != null) {
        extractedData['fullName'] = nameCandidate.label.trim();
        unclassified.remove(nameCandidate);
      }
    }

    if (dobAnchor != null && yearAnchor != null) {
      Bbox? classCandidate;

      for (final bbox in unclassified) {
        bool isBetween =
            bbox.yMin > dobAnchor!.yMax && bbox.yMax < yearAnchor!.yMin;
        bool isAligned = _isHorizontallyAligned(bbox, dobAnchor!);
        if (isBetween && isAligned) {
          classCandidate = bbox;
          break;
        }
      }

      if (classCandidate != null) {
        extractedData['className'] = classCandidate.label.trim();
        unclassified.remove(classCandidate);
      }
    }

    final studentInfo = StudentInformation(
      fullName: extractedData['fullName'] ?? "",
      studentId: extractedData['studentId'] ?? "",
      dateOfBirth: extractedData['dateOfBirth'] ?? "",
      className: extractedData['className'] ?? "",
      year: extractedData['year'] ?? "",
    );

    return studentInfo;
  }

  bool _isHorizontallyAligned(Bbox box1, Bbox box2, {double tolerance = 50.0}) {
    final box1CenterX = (box1.xMin + box1.xMax) / 2;
    final box2CenterX = (box2.xMin + box2.xMax) / 2;

    return (box1CenterX - box2CenterX).abs() < tolerance;
  }
}
