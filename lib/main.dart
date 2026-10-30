import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/student_service.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style to match modern GradeFlow aesthetic
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const GradeFlowApp());
}

/// Root widget of the GradeFlow application.
class GradeFlowApp extends StatelessWidget {
  const GradeFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StudentService>(
      create: (_) => StudentService(),
      child: MaterialApp(
        title: 'GradeFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
