import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/student_dashboard.dart';
import '../views/admin_dashboard.dart';
import '../views/login_screen.dart';
import 'dart:math' as math; // 👈 Add this line to fix the 'math' error instantly!

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 📱 MOBILE CORE REVERSIBLE PROPERTIES: Tracks live user tokens
  late Rx<User?> _firebaseUser;
  
  // Reactive UI state loaders
  var isLoading = false.obs;

  // Flag to ensure splash/warmup delay only executes exactly once on app boot up
  bool _isInitialBootComplete = false;

  // Getter to securely expose the user object properties if needed across screens
  User? get user => _firebaseUser.value;

  @override
  void onInit() {
    super.onInit();
    // Re-linking your mobile initialization matrix
    _firebaseUser = Rx<User?>(_auth.currentUser);
    
    // Binds the Rx variable to live authentication status updates from Firebase
    _firebaseUser.bindStream(_auth.userChanges());
    
    // Workers track user changes and trigger the routing sequence automatically
    ever(_firebaseUser, _handleInitialRouting);
  }

  // --- ROLE-BASED SYSTEM ROUTING MATRIX ---
  Future<void> _handleInitialRouting(User? user) async {
    // 🚀 FIXED: Artificial holding matrix delay ONLY runs once during initial app boot up.
    // This stops it from pausing the main UI thread during a live user click sign-in process!
    if (!_isInitialBootComplete) {
      await Future.delayed(const Duration(seconds: 3));
      _isInitialBootComplete = true;
    }

    if (user == null) {
      Get.offAll(() => LoginScreen());
    } else {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          String role = (userDoc.data() as Map<String, dynamic>)['role'] ?? 'student';

          if (role.toLowerCase() == 'admin') {
            Get.offAll(() => const AdminDashboard());
          } else {
            Get.offAll(() => const StudentDashboard());
          }
        } else {
          // Fallback node route
          Get.offAll(() => const StudentDashboard());
        }
      } catch (e) {
        Get.snackbar("Routing Engine Error", e.toString());
        Get.offAll(() => LoginScreen());
      }
    }
  }

  // --- COHESIVE USER VALIDATION HANDSHAKE ---
  Future<void> loginUser(String email, String password, int selectedRoleIndex) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      Get.snackbar(
        "AUTHENTICATION ERROR", 
        "All parameter keys must be fully populated.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFBA1A1A),
        colorText: Colors.white,
        borderRadius: 4,
      );
      return;
    }

    // Client-side quick email pattern checking to protect pipeline logs
    if (!GetUtils.isEmail(email.trim())) {
      Get.snackbar(
        "INVALID EMAIL FORMAT",
        "Please enter a standard institutional handle (e.g., admin@hostelhub.com).",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFBA1A1A),
        colorText: Colors.white,
        borderRadius: 4,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Executing credential processing over Firebase core nodes asynchronously
      await _auth.signInWithEmailAndPassword(
        email: email.trim(), 
        password: password.trim(),
      );

      // NOTE: We do not call Get.offAll() here anymore! 
      // The ever() worker above will catch this login instantly and handle routing safely without blocking.

    } on FirebaseAuthException catch (e) {
      String friendlyMessage = "Authentication failed. Secure parameters rejected.";
      
      if (e.code == 'invalid-credential') {
        friendlyMessage = "The password or account handle provided is incorrect or has expired.";
      } else if (e.code == 'user-not-found') {
        friendlyMessage = "No user registry parameters found matching this identity.";
      } else if (e.code == 'wrong-password') {
        friendlyMessage = "Secure key entry verification failed.";
      }

      Get.snackbar(
        "LOGIN FAILED", 
        friendlyMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFBA1A1A),
        colorText: Colors.white,
        borderRadius: 4,
      );
    } catch (e) {
      Get.snackbar("SYSTEM ERROR", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}