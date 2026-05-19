import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'landing_page.dart'; // Ensure this matches your file layout structure

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Setup a clean fade-in animation for your branding logo/text
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();

    // 2. CRITICAL FIX: Direct, safe GetX transition logic chain
    // Using Get.offAll ensures the splash screen is completely popped from memory stack
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Get.offAll(
          () => const LandingPage(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 800),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Matches landing page background base color
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Your Premium Brand Mark
              Text(
                "HOSTELHUB",
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 6.0,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "INTELLIGENT CAMPUS LIVING",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF99A98F),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(height: 50),
              // Ultra-lightweight performance safe loading indicator
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Color(0xFF99A98F),
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}