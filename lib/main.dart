import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/student_service.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable true edge-to-edge full-screen display (removes black letterboxing bars)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const GradeFlowApp());
}

/// Root widget of the GradeFlow application with dynamic ThemeMode support.
class GradeFlowApp extends StatelessWidget {
  const GradeFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StudentService>(
      create: (_) => StudentService(),
      child: Consumer<StudentService>(
        builder: (context, studentService, child) {
          // Check if dark theme is currently effective
          final isDarkEffective = studentService.themeMode == ThemeMode.dark ||
              (studentService.themeMode == ThemeMode.system &&
                  MediaQuery.platformBrightnessOf(context) == Brightness.dark);

          final overlayStyle = SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDarkEffective ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDarkEffective ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: isDarkEffective ? Brightness.light : Brightness.dark,
            systemNavigationBarContrastEnforced: false,
            systemStatusBarContrastEnforced: false,
          );

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: overlayStyle,
            child: MaterialApp(
              title: 'GradeFlow',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: studentService.themeMode,
              home: const SplashScreen(),
            ),
          );
        },
      ),
    );
  }
}
