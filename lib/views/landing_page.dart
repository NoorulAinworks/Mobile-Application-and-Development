import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'login_screen.dart'; // Make sure this path points correctly to your file layout

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late AnimationController _compassController;
  late ScrollController _scrollController;
  late PageController _backgroundPageController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier<double>(0.0);
  int _currentImageIndex = 0;
  Timer? _slideshowTimer;

  // Verification flags
  bool _assetsValidated = false;

  final List<String> slideshowImages = [
    'assets/pic1.jpg',
    'assets/pic2.jpg',
    'assets/pic3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    
    _scrollController = ScrollController();
    _backgroundPageController = PageController(initialPage: 0);

    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        _scrollOffsetNotifier.value = _scrollController.offset;
      }
    });

    _compassController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Safely trigger asset checking
    _validateAndStartTimer();
  }

  void _validateAndStartTimer() {
    // We delay the slide timer execution safely until layout parameters clear initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _assetsValidated = true;
        });
        
        _slideshowTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
          if (mounted && _backgroundPageController.hasClients) {
            int nextIndex = (_currentImageIndex + 1) % slideshowImages.length;
            _currentImageIndex = nextIndex;
            
            _backgroundPageController.animateToPage(
              nextIndex,
              duration: const Duration(milliseconds: 1200),
              curve: Curves.fastOutSlowIn, 
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _compassController.dispose();
    _backgroundPageController.dispose();
    _slideshowTimer?.cancel();
    _scrollOffsetNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0D0D0D),
      
      drawer: SizedBox(
        width: isMobile ? screenSize.width * 0.85 : 320,
        child: Drawer(
          backgroundColor: const Color(0xFA111111),
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 60, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                  onPressed: () => _scaffoldKey.currentState?.closeDrawer(),
                ),
                SizedBox(height: isMobile ? 30 : 60),
                Text(
                  "INSPIRING GREATNESS",
                  style: GoogleFonts.poppins(color: const Color(0xFF99A98F), letterSpacing: 3.0, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 40),
                _buildDrawerLink("PORTAL HOME", () => _scaffoldKey.currentState?.closeDrawer()),
                _buildDrawerLink("CAMPUS AMENITIES", () {
                  _scaffoldKey.currentState?.closeDrawer();
                  _scrollController.animateTo(screenSize.height * 1.5, duration: const Duration(milliseconds: 600), curve: Curves.decelerate);
                }),
                _buildDrawerLink("OUR PHILOSOPHY", () {
                  _scaffoldKey.currentState?.closeDrawer();
                  _scrollController.animateTo(screenSize.height * 0.9, duration: const Duration(milliseconds: 600), curve: Curves.decelerate);
                }),
                _buildDrawerLink("SYSTEM GATEWAY", () {
                  _scaffoldKey.currentState?.closeDrawer();
                  Get.to(() => const LoginScreen(), transition: Transition.fadeIn);
                }),
              ],
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          // 1. LIVE PARALLAX SLIDESHOW ENGINE LAYER
          ValueListenableBuilder<double>(
            valueListenable: _scrollOffsetNotifier,
            builder: (context, offset, child) {
              return Positioned(
                top: -offset * 0.35,
                left: 0,
                right: 0,
                height: screenSize.height * 1.2,
                child: child!,
              );
            },
            child: Stack(
              children: [
                _assetsValidated
                    ? PageView.builder(
                        controller: _backgroundPageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: slideshowImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D0D0D), // Safe black fallback layout
                              image: DecorationImage(
                                image: AssetImage(slideshowImages[index]),
                                fit: BoxFit.cover,
                                onError: (_, __) {}, // Suppresses silent missing image asset crashes
                              ),
                            ),
                          );
                        },
                      )
                    : Container(color: const Color(0xFF0D0D0D)),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.15),
                        const Color(0xFF0D0D0D),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. SCROLLABLE CONTENT LAYER
          SafeArea(
            top: false,
            bottom: false,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  // --- SECTION 1: THE HERO CANVAS ---
                  Container(
                    constraints: BoxConstraints(minHeight: screenSize.height > 0 ? screenSize.height : 600),
                    width: screenSize.width,
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40, vertical: 80),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 80),
                        Text(
                          "YOUR SEAMLESS\nCAMPUS EXPERIENCE",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzel(
                            color: Colors.white,
                            fontSize: isMobile ? 28 : (screenSize.width < 800 ? 36 : 56),
                            fontWeight: FontWeight.w400,
                            letterSpacing: isMobile ? 4.0 : 8.0,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "THE PREMIER STUDENT RESIDENCE FOR NTU",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF99A98F),
                            fontSize: isMobile ? 11 : 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: isMobile ? 2.5 : 5.0,
                        ),
                      ),
                      const SizedBox(height: 50),
                      
                      InkWell(
                        onTap: () => Get.to(() => const LoginScreen(), transition: Transition.fadeIn, duration: const Duration(milliseconds: 500)),
                        borderRadius: BorderRadius.circular(40),
                        child: Container(
                          width: isMobile ? 220 : 260,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Center(
                            child: Text(
                              "DASHBOARD",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF0D0D0D),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      
                      RotationTransition(
                        turns: _compassController,
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF99A98F).withOpacity(0.4), width: 1),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                              Positioned(top: 2, child: Container(width: 1.5, height: 8, color: const Color(0xFF99A98F))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- SECTION 2: PHILOSOPHY ---
                Container(
                  color: const Color(0xFF0D0D0D),
                  width: screenSize.width,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 80 : 140, horizontal: screenSize.width < 800 ? 20 : 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "01 / PHILOSOPHY",
                        style: GoogleFonts.poppins(color: const Color(0xFF99A98F), letterSpacing: 4.0, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: 800,
                        child: Text(
                          "HostelHub completely redefines institutional living. Designed specifically for the modern pace of National Textile University engineering steps, it pairs minimalist architecture with cloud automated management systems, giving your campus residency unparalleled clarity.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzel(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isMobile ? 18 : (screenSize.width < 800 ? 20 : 28),
                            height: 1.8,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- SECTION 3: THE AMENITIES ---
                Container(
                  color: const Color(0xFF090909),
                  width: screenSize.width,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 80 : 120, horizontal: screenSize.width < 800 ? 20 : 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: isMobile ? 10 : 20, bottom: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("02 / ECOSYSTEM", style: GoogleFonts.poppins(color: const Color(0xFF99A98F), letterSpacing: 4.0, fontSize: 12, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 10),
                            Text("THE UTILITY LAYER", style: GoogleFonts.cinzel(color: Colors.white, fontSize: isMobile ? 26 : 32, letterSpacing: 2.0)),
                          ],
                        ),
                      ),
                      Center(
                        child: Wrap(
                          spacing: 30,
                          runSpacing: 30,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildPremiumFeatureCard("01", "REALTIME LOGGING", "Instant digital submission for campus and maintenance grievances directly to management channels.", screenSize.width),
                            _buildPremiumFeatureCard("02", "SECURE PORTALS", "Segmented authorization profiles protecting admin structures from student views securely.", screenSize.width),
                            _buildPremiumFeatureCard("03", "REACTIVE ECOSYSTEM", "Clean, high contrast dashboard layouts configured with layout stability protections.", screenSize.width),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

          // 3. FIXED NAVIGATION HEADER BAR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xEE0D0D0D),
                    Color(0x000D0D0D),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
                            const SizedBox(width: 12),
                            Text(
                              "HOSTELHUB",
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.w600, letterSpacing: isMobile ? 2.0 : 4.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.to(() => const LoginScreen(), transition: Transition.fadeIn),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF99A98F).withOpacity(0.6), width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "ENTER PORTAL",
                          style: GoogleFonts.poppins(color: const Color(0xFF99A98F), fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. FLOATING SCREEN INDICATORS
          if (!isMobile)
            ValueListenableBuilder<double>(
              valueListenable: _scrollOffsetNotifier,
              builder: (context, offset, child) {
                return Positioned(
                  left: 40,
                  top: screenSize.height * 0.45,
                  child: Column(
                    children: [
                      _buildTrackIndicator(offset < screenSize.height * 0.5),
                      const SizedBox(height: 18),
                      _buildTrackIndicator(offset >= screenSize.height * 0.5 && offset < screenSize.height * 1.3),
                      const SizedBox(height: 18),
                      _buildTrackIndicator(offset >= screenSize.height * 1.3),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTrackIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF99A98F) : Colors.transparent,
        border: Border.all(color: isActive ? const Color(0xFF99A98F) : Colors.white30, width: 1),
      ),
    );
  }

  Widget _buildDrawerLink(String title, VoidCallback action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: InkWell(
        onTap: action,
        child: Text(
          title,
          style: GoogleFonts.cinzel(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 2.0),
        ),
      ),
    );
  }

  Widget _buildPremiumFeatureCard(String index, String title, String description, double currentScreenWidth) {
    double cardWidth = currentScreenWidth < 400 ? (currentScreenWidth - 40) : 320;
    
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(30),
      color: const Color(0xFF121212),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(index, style: GoogleFonts.poppins(color: const Color(0xFF99A98F), fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 20),
          Text(title, style: GoogleFonts.cinzel(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 1.5)),
          const SizedBox(height: 15),
          Text(
            description,
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12, height: 1.6, fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}