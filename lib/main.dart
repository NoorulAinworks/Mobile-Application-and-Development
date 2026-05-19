import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:get/get.dart'; // Required for our custom page navigation routing
import 'app_theme.dart';
import 'views/login_screen.dart'; 
import 'views/landing_page.dart';
import 'views/splash_screen.dart'; // Fixed leading slash to keep path relative and clean

// 🚀 IMPORT YOUR SYSTEM CONTROLLERS HERE:
import 'controllers/auth_controller.dart';
import 'controllers/complaint_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // KEEPING INTACT: Your logic for running on both web/browser and mobile phones
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCyc3MSwmf-GUBbxPjV3_cJSmfTdeRcPbM",
        authDomain: "hostel-hub-2c5d5.firebaseapp.com",
        projectId: "hostel-hub-2c5d5",
        storageBucket: "hostel-hub-2c5d5.firebasestorage.app",
        messagingSenderId: "315608473287",
        appId: "1:315608473287:web:bbee0f236701910b7768e2",
        measurementId: "G-92S0HW5MD7",
      ),
    );
  } else {
    // Android uses the google-services.json file automatically
    await Firebase.initializeApp();
  }

  // 👑 DEPENDENCY INJECTION LAYER (Safely binds controllers before the UI boots)
  Get.put(AuthController());
  Get.put(ComplaintController());

  runApp(const HostelHubApp());
}

class HostelHubApp extends StatelessWidget {
  const HostelHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Upgraded to GetMaterialApp so your custom login/signup animations transition smoothly
    return GetMaterialApp(
      title: 'HostelHub',
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fadeIn,
      theme: AppTheme.lightTheme,
      
      // Points directly to the file where your exact mockup layout is written
      home: const SplashScreen(),
    );
  }
}