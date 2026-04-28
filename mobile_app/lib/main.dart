import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/constants/app_colors.dart';
import 'features/splash/splash_view.dart';
import 'services/mongo_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await MongoService.connect();

  runApp(const JobAbleApp());
}

class JobAbleApp extends StatelessWidget {
  const JobAbleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobAble',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: AppColors.primaryNavy,
        useMaterial3: true,
      ),
      home: const SplashView(),
    );
  }
}
