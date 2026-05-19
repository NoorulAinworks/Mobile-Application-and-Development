import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import 'signup_screen.dart';
import 'student_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());
  
  int selectedRoleIndex = 0; // 0 = Student, 1 = Administrator
  bool isPasswordHidden = true; 

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900; 

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), 
      body: SafeArea(
        child: isMobile 
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      children: [
                        _buildLeftPanel(context, isMobile: true, height: 200),
                        _buildRightPanel(context, isMobile: true),
                      ],
                    ),
                  );
                },
              )
            : Row(
                children: [
                  Expanded(flex: 1, child: _buildLeftPanel(context, isMobile: false)),
                  Expanded(
                    flex: 1, 
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: _buildRightPanel(context, isMobile: false),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context, {required bool isMobile, double? height}) {
    return Container(
      height: height ?? double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        border: Border(
          right: BorderSide(color: Color(0xFF1A1A1A), width: 1), 
          bottom: BorderSide(color: Color(0xFF1A1A1A), width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24.0 : 60.0, 
        vertical: isMobile ? 20.0 : 40.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          RichText(
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "HOSTEL",
                  style: GoogleFonts.cinzel(
                    color: Colors.white, 
                    fontSize: isMobile ? 32 : 42,
                    fontWeight: FontWeight.w300,
                    letterSpacing: isMobile ? 4.0 : 6.0,
                  ),
                ),
                TextSpan(
                  text: "HUB",
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFF99A98F), 
                    fontSize: isMobile ? 32 : 42,
                    fontWeight: FontWeight.w600,
                    letterSpacing: isMobile ? 4.0 : 6.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Your seamless NTU experience starts here.",
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.4), 
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(BuildContext context, {required bool isMobile}) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 540), 
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24.0 : 60.0, 
        vertical: isMobile ? 30.0 : 0.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Sign In",
            style: GoogleFonts.cinzel(
              color: Colors.white, 
              fontSize: isMobile ? 24 : 28, 
              fontWeight: FontWeight.w400,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: isMobile ? 20 : 30),

          _buildRoleToggleSwitch(),
          SizedBox(height: isMobile ? 30 : 40),

          _buildInputLabel("Institutional Email Address"),
          const SizedBox(height: 10),
          _buildTextField(
            controller: emailController,
            hintText: "username@ntu.edu.pk",
            prefixIcon: Icons.school_outlined,
          ),
          const SizedBox(height: 25),

          _buildInputLabel("Security Access Password"),
          const SizedBox(height: 10),
          _buildTextField(
            controller: passwordController,
            hintText: "••••••••",
            prefixIcon: Icons.lock_open_outlined,
            isPassword: true,
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.white.withOpacity(0.3),
                size: 20,
              ),
              onPressed: () => setState(() => isPasswordHidden = !isPasswordHidden),
            ),
          ),
          SizedBox(height: isMobile ? 35 : 45),

          Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF99A98F), 
                  foregroundColor: const Color(0xFF0A0A0A), 
                  minimumSize: const Size(double.infinity, 54), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
                  elevation: 0,
                ),
                onPressed: _authController.isLoading.value 
                    ? null 
                    : () {
                        _authController.loginUser(
                          emailController.text,
                          passwordController.text,
                          selectedRoleIndex,
                        );
                      },
                child: _authController.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Color(0xFF0A0A0A), strokeWidth: 2),
                      )
                    : Text(
                        "CONTINUE",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.5,
                        ),
                      ),
          )),

          const SizedBox(height: 35),

          // 🚀 FIXED: Only shows the Sign Up redirection if STUDENT is selected (index == 0)
          if (selectedRoleIndex == 0)
            Center(
              child: GestureDetector(
                onTap: () {
                  // Clean up internal routing selections before switching panels
                  setState(() => selectedRoleIndex = 0);
                  Get.to(
                    () => const SignUpPage(), 
                    transition: Transition.rightToLeftWithFade, 
                    duration: const Duration(milliseconds: 700)
                  );
                },
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(fontSize: 13, letterSpacing: 0.5),
                    children: [
                      TextSpan(text: "Don't have an account? ", style: TextStyle(color: Colors.white.withOpacity(0.4))),
                      const TextSpan(text: "Sign Up", style: TextStyle(color: Color(0xFF99A98F), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        color: Colors.white.withOpacity(0.4),
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? isPasswordHidden : false,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF121212), 
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: Colors.white.withOpacity(0.25), size: 20),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF99A98F), width: 1), 
        ),
      ),
    );
  }

  Widget _buildRoleToggleSwitch() {
    return Container(
      width: double.infinity,
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1A1A1A), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedRoleIndex = 0),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedRoleIndex == 0 ? const Color(0xFF1C1C1C) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: selectedRoleIndex == 0 ? Border.all(color: const Color(0xFF2A2A2A), width: 1) : null,
                ),
                child: Center(
                  child: Text(
                    "STUDENT",
                    style: GoogleFonts.inter(
                      color: selectedRoleIndex == 0 ? const Color(0xFF99A98F) : Colors.white.withOpacity(0.3),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedRoleIndex = 1),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedRoleIndex == 1 ? const Color(0xFF1C1C1C) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: selectedRoleIndex == 1 ? Border.all(color: const Color(0xFF2A2A2A), width: 1) : null,
                ),
                child: Center(
                  child: Text(
                    "ADMINISTRATOR",
                    style: GoogleFonts.inter(
                      color: selectedRoleIndex == 1 ? const Color(0xFF99A98F) : Colors.white.withOpacity(0.3),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}