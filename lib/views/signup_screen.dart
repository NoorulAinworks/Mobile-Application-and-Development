import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; 

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;

  TextStyle _interFont(double size, FontWeight weight, {Color color = Colors.white}) {
    return GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "REGISTRATION ERROR",
        "All pipeline validation parameters must be populated.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFBA1A1A),
        colorText: Colors.white,
        borderRadius: 4,
        margin: const EdgeInsets.all(20),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Create the user authentication matrix in Firebase
      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Fire-and-forget the Firestore registration document write.
      // We do NOT 'await' this here in the UI thread. This prevents the UI from locking up
      // and lets your background AuthGate handle the navigation immediately without lag.
      FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'name': name,
        'email': email,
        'role': 'student', 
        'createdAt': FieldValue.serverTimestamp(),
      }).catchError((error) {
        print("Error writing to Firestore: $error");
      });

      // Show a quick native notification success overlay
      Get.rawSnackbar(
        title: "REGISTRATION COMPLETE",
        message: "Profile verified.",
        backgroundColor: const Color(0xFF99A98F),
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      // If authentication fails, reset loading state safely
      if (mounted) {
        setState(() => _isLoading = false);
      }
      
      Get.snackbar(
        "REGISTRATION FAILED",
        e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFBA1A1A),
        colorText: Colors.white,
        borderRadius: 4,
        margin: const EdgeInsets.all(20),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 20.0 : 40.0),
            child: Container(
              width: isMobile ? double.infinity : 450,
              padding: EdgeInsets.all(isMobile ? 24.0 : 40.0),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF1A1A1A)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "HOSTEL",
                          style: GoogleFonts.cinzel(
                            color: Colors.white, 
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 3.0,
                          ),
                        ),
                        TextSpan(
                          text: "HUB",
                          style: GoogleFonts.cinzel(
                            color: const Color(0xFF99A98F), 
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Register standard credentials to clear database entry points.",
                    style: _interFont(13, FontWeight.normal, color: Colors.white38),
                  ),
                  const SizedBox(height: 35),
                  
                  _buildInputLabel("FULL NAME ENTRY"),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: _inputDecoration("Noor ul Ain", Icons.person_outline),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildInputLabel("EMAIL ADDRESS MATRIX"),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: _inputDecoration("student@domain.edu.pk", Icons.school_outlined),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildInputLabel("SECURITY ACCESS KEYWAY (PASSWORD)"),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: _inputDecoration("••••••••••••", Icons.lock_open_outlined),
                  ),
                  const SizedBox(height: 40),
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF99A98F),
                      foregroundColor: const Color(0xFF0A0A0A),
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _handleSignUp,
                    child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF0A0A0A), strokeWidth: 2))
                        : Text(
                            "DISPATCH REGISTRATION LEDGER", 
                            style: GoogleFonts.inter(
                              fontSize: 12, 
                              fontWeight: FontWeight.w600, 
                              letterSpacing: 1.5
                            ),
                          ),
                  ),
                  const SizedBox(height: 30),
                  
                  Center(
                    child: InkWell(
                      onTap: () => Get.to(() => const LoginScreen(), transition: Transition.leftToRightWithFade, duration: const Duration(milliseconds: 700)),
                      child: RichText(
                        text: TextSpan(
                          style: _interFont(12, FontWeight.normal, color: Colors.white38),
                          children: [
                            const TextSpan(text: "Existing session creds? "),
                            TextSpan(text: "ACCESS PANEL", style: TextStyle(color: const Color(0xFF99A98F), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        label, 
        style: GoogleFonts.inter(
          color: Colors.white.withOpacity(0.4),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData prefixIcon) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF121212),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: Colors.white.withOpacity(0.25), size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0xFF99A98F), width: 1),
      ),
    );
  }
}