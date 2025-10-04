import 'package:extract_information_student_card_app/services/card_classification_service.dart';
import 'package:extract_information_student_card_app/utils/image_utils.dart';
import 'package:extract_information_student_card_app/utils/types.dart';
import 'package:flutter/material.dart';
import 'package:onnxruntime/onnxruntime.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  OrtEnv.instance.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Scaffold(body: Center(child: MyWidget())));
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  Future<CardType> classify(String imagePath) async {
    var service = CardClassificationService();
    await service.initialize();
    return await service.classify(
      await ImageUtils.loadImageFromAssets(imagePath),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CardType>(
      future: classify("assets/images/24T1020557_TheThuVien.jpg"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return Text('Card Type: ${snapshot.data}');
        } else {
          return const Text('No data');
        }
      },
    );
  }
}
