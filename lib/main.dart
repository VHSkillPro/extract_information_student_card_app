import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:extract_information_student_card_app/views/home_view.dart';
import 'package:extract_information_student_card_app/viewmodels/home_viewmodel.dart';
import 'package:extract_information_student_card_app/viewmodels/camera_viewmodel.dart';
import 'package:extract_information_student_card_app/viewmodels/edit_crop_viewmodel.dart';
import 'package:extract_information_student_card_app/viewmodels/verification_information_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  OrtEnv.instance.init();

  // final textDetectionService = LibraryCardTextDetectionService();
  // await textDetectionService.initialize();

  // final String imagePath = "assets/images/24T1020413_TheThuVien.jpg";
  // final image = await ImageUtils.loadImageFromAssets(imagePath);
  // DetResultList detResultList = await textDetectionService.detect(image);

  // print(detResultList.count);
  // for (int i = 0; i < detResultList.count; i++) {
  //   DetResult detResult = detResultList.data[i];
  //   print(
  //     '${detResult.box[0]}, ${detResult.box[1]}, ${detResult.box[2]}, ${detResult.box[3]}, ${detResult.box[4]}, ${detResult.box[5]}, ${detResult.box[6]}, ${detResult.box[7]}',
  //   );
  // }

  // textDetectionService.freeResult(detResultList);

  // final textRecognitionService = TextRecognitionService();
  // await textRecognitionService.initialize();

  // final String recogImagePath = "assets/images/text_4.jpg";
  // final _image = await ImageUtils.loadImageFromAssets(recogImagePath);
  // final result = await textRecognitionService.recognize(_image);

  // print('Recognized Text: $result');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => CameraViewModel()),
        ChangeNotifierProvider(create: (_) => EditCropViewModel()),
        ChangeNotifierProvider(
          create: (_) => VerificationInformationViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Ứng dụng trích xuất thông tin thẻ sinh viên',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: const HomeView(),
      ),
    );
  }
}
