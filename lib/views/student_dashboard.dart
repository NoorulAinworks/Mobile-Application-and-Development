import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'dart:math' as math;

import '../controllers/auth_controller.dart';
import '../controllers/complaint_controller.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final AuthController _authController = Get.find<AuthController>();
  
  late final ComplaintController _complaintController;
  late final Stream<QuerySnapshot> _studentComplaintsStream;

  // Form Controllers declared at the State level to prevent memory leaks
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  int activeNavigationIndex = 0;
  
  String selectedCategory = "Electricity"; 
  final List<String> categories = ["Electricity", "Plumbing & Water", "Internet & Wi-Fi", "Housekeeping", "Mess/Food", "Other"];

  String _studentEmail = 'student@ntu.edu.pk';
  String _shortUidHex = 'N/A';

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ComplaintController>()) {
      _complaintController = Get.find<ComplaintController>();
    } else {
      _complaintController = Get.put(ComplaintController());
    }

    _studentComplaintsStream = _complaintController.streamStudentComplaints();

    // Instantiate controllers exactly once
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    final firebase_auth.User? currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _studentEmail = currentUser.email ?? 'student@ntu.edu.pk';
      _shortUidHex = currentUser.uid.substring(0, math.min(8, currentUser.uid.length)).toUpperCase();
    }
  }

  @override
  void dispose() {
    // Clean up controllers immediately when the dashboard destroys to free memory channels
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  TextStyle _interFont(double size, FontWeight weight, {Color color = Colors.white, double letterSpacing = 0.0}) {
    return GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color, letterSpacing: letterSpacing);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          drawer: isMobile ? Drawer(
            backgroundColor: const Color(0xFF111111),
            child: _buildSidebarContents(isMobile: true),
          ) : null,
          appBar: isMobile ? AppBar(
            backgroundColor: const Color(0xFF111111),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              "HOSTELHUB", 
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white, 
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 1.5
              ),
            ),
            shape: const Border(bottom: BorderSide(color: Color(0xFF1A1A1A))),
          ) : null,
          body: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.12,
                    child: Stack(
                      children: [
                        Positioned(top: 60, left: isMobile ? 30 : 120, child: const Text("★", style: TextStyle(color: Color(0xFF99A98F), fontSize: 14))),
                        Positioned(top: 240, right: 80, child: const Text("★", style: TextStyle(color: Color(0xFF99A98F), fontSize: 10))),
                        Positioned(bottom: 180, left: isMobile ? 40 : 340, child: const Text("★", style: TextStyle(color: Color(0xFF99A98F), fontSize: 16))),
                        Positioned(top: 450, left: isMobile ? 280 : 500, child: const Text("★", style: TextStyle(color: Color(0xFF99A98F), fontSize: 12))),
                        Positioned(bottom: 90, right: isMobile ? 40 : 220, child: const Text("★", style: TextStyle(color: Color(0xFF99A98F), fontSize: 15))),
                        if (!isMobile) ...[
                          Positioned(top: 150, left: 400, child: const Text("★", style: TextStyle(color: Color(0xFF99A98F), fontSize: 11))),
                          Positioned(bottom: 300, right: 450, child: const Text("★", style: TextStyle(color: Color(0xFF99A98F), fontSize: 13))),
                        ]
                      ],
                    ),
                  ),
                ),
              ),

              Row(
                children: [
                  if (!isMobile)
                    Container(
                      width: 260,
                      decoration: const BoxDecoration(
                        color: Color(0xFF111111),
                        border: Border(right: BorderSide(color: Color(0xFF1A1A1A))),
                      ),
                      child: _buildSidebarContents(isMobile: false),
                    ),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 16.0 : 40.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeNavigationIndex == 2 
                                ? "HOSTEL SECTORS" 
                                : activeNavigationIndex == 3 
                                    ? "ACCOUNT PROFILE" 
                                    : "SYSTEM OVERVIEW", 
                            style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: isMobile ? 22 : 28, fontWeight: FontWeight.w400, letterSpacing: 1.0),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activeNavigationIndex == 2 
                                ? "Click any active sector registry block down below to immediately dispatch a directed complaint ticket."
                                : activeNavigationIndex == 3
                                    ? "Real-time structural authorization metrics for this active credential node."
                                    : "Real-time verification metrics for Noor ul Ain", 
                            style: _interFont(isMobile ? 11 : 13, FontWeight.normal, color: Colors.white38),
                          ),
                          SizedBox(height: isMobile ? 24 : 40),
                          
                          Expanded(
                            child: IndexedStack(
                              index: activeNavigationIndex,
                              children: [
                                _buildOverviewTab(isMobile),
                                _buildNewComplaintTab(isMobile),
                                _buildOperationalSectorsTab(),
                                _buildStudentProfileTab(isMobile),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildSidebarContents({required bool isMobile}) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                "HOSTELHUB", 
                style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
            ),
          SizedBox(height: isMobile ? 12 : 20),
          _buildSidebarItem(0, "OVERVIEW", Icons.dashboard_outlined, isMobile),
          _buildSidebarItem(1, "NEW COMPLAINT", Icons.add_circle_outline, isMobile),
          _buildSidebarItem(2, "OPERATIONAL SECTORS", Icons.business_outlined, isMobile),
          _buildSidebarItem(3, "MY PROFILE ACCOUNT", Icons.person_outline, isMobile),
          const Spacer(),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () async {
                try {
                  await firebase_auth.FirebaseAuth.instance.signOut();
                  Get.deleteAll(force: true);
                  Get.offAllNamed('/');
                } catch (e) {
                  Get.snackbar(
                    "LOGOUT ERROR", 
                    "Failed to securely clean app session.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF151515),
                    colorText: Colors.redAccent,
                  );
                }
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF5555).withOpacity(0.2)), 
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Color(0xFFFF5555), size: 18),
                    const SizedBox(width: 12),
                    Text("TERMINATE SESSION", style: _interFont(11, FontWeight.w600, color: const Color(0xFFFF5555), letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(bool isMobile) {
    return StreamBuilder<QuerySnapshot>(
      stream: _studentComplaintsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator(color: Color(0xFF99A98F))));
        }

        final docs = snapshot.data?.docs ?? [];
        int totalLogged = docs.length;
        int pendingCount = docs.where((d) => (d.data() as Map)['status'].toString().toUpperCase() == 'PENDING').length;
        int resolvedCount = docs.where((d) => (d.data() as Map)['status'].toString().toUpperCase() == 'RESOLVED').length;

        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Wrap(
              spacing: isMobile ? 12 : 25, 
              runSpacing: isMobile ? 12 : 25,
              children: [
                _buildMetricCard("TOTAL LOGGED", totalLogged, Icons.folder_open, isMobile),
                _buildMetricCard("PENDING ACTIONS", pendingCount, Icons.hourglass_empty, isMobile),
                _buildMetricCard("RESOLVED TICKETS", resolvedCount, Icons.assignment_turned_in, isMobile),
              ],
            ),
            SizedBox(height: isMobile ? 32 : 50),
            Text("RECENT ACTIVITY HISTORICAL STREAM", style: _interFont(11, FontWeight.w600, color: Colors.white38, letterSpacing: 1.0)),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF1A1A1A))),
              child: docs.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Center(child: Text("NO CURRENT LODGED GRIEVANCES DEPLOYED", style: _interFont(11, FontWeight.w600, color: Colors.white24, letterSpacing: 1.0))),
                    )
                  : Column(
                      children: docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        String rawStatus = data['status'] ?? 'Pending';
                        String status = rawStatus.toUpperCase();
                        Color statusColor = status == 'RESOLVED' ? const Color(0xFF99A98F) : const Color(0xFFE2B93B);

                        return _buildRecordRow(data['complaintId'] ?? '#HH-XXXXXX', data['title'] ?? 'No Details Provided', rawStatus, statusColor, isMobile);
                      }).toList(),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNewComplaintTab(bool isMobile) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 600),
          padding: EdgeInsets.all(isMobile ? 18 : 32),
          decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF1A1A1A))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SUBMIT NEW HOUSE COMPLAINT", style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildFormLabel("SELECT COMPLAINT CATEGORY"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(4)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    dropdownColor: const Color(0xFF111111),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    items: categories.map((String val) => DropdownMenuItem<String>(value: val, child: Text(val))).toList(),
                    onChanged: (val) { if (val != null) setState(() => selectedCategory = val); },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildFormLabel("COMPLAINT TITLE SUMMARY"),
              TextField(controller: _titleController, style: const TextStyle(color: Colors.white), decoration: _formDecoration("e.g., Room 302 Ceiling Fan Not Working")),
              const SizedBox(height: 20),
              _buildFormLabel("DETAILED DESCRIPTION"),
              TextField(controller: _descriptionController, maxLines: 4, style: const TextStyle(color: Colors.white), decoration: _formDecoration("Describe the issue clearly...")),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF99A98F), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                onPressed: () async {
                  if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) return;
                  bool created = await _complaintController.createComplaint(
                    title: _titleController.text.trim(),
                    description: _descriptionController.text.trim(),
                    category: selectedCategory, 
                  );
                  if (created) {
                    // Safe cleanup routine to zero out inputs on form success
                    _titleController.clear();
                    _descriptionController.clear();
                    setState(() {
                      selectedCategory = "Electricity";
                      activeNavigationIndex = 0;
                    });
                  }
                },
                child: Text("DISPATCH LIVE COMPLAINT TICKET", style: _interFont(13, FontWeight.bold, color: Colors.black)),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOperationalSectorsTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _buildSectorCard("ELECTRICITY", "Electricity", "Warden Wing A", "Operational", true),
            _buildSectorCard("INTERNET & WI-FI", "Internet & Wi-Fi", "IT Support Desk", "2 Active Outages", false),
            _buildSectorCard("PLUMBING & WATER", "Plumbing & Water", "Warden Wing B", "Operational", true),
            _buildSectorCard("HOUSEKEEPING", "Housekeeping", "Main Janitorial", "Operational", true),
          ],
        ),
      ],
    );
  }

  Widget _buildStudentProfileTab(bool isMobile) {
    return StreamBuilder<QuerySnapshot>(
      stream: _studentComplaintsStream,
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        int totalSubmitted = docs.length;
        int activePending = docs.where((d) => (d.data() as Map)['status'].toString().toUpperCase() != 'RESOLVED').length;
        int resolvedCount = totalSubmitted - activePending;

        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Wrap(
              spacing: isMobile ? 12 : 20,
              runSpacing: isMobile ? 12 : 20,
              children: [
                _buildProfileMetricTile("YOUR SUBMISSIONS", totalSubmitted, const Color(0xFF99A98F), isMobile),
                _buildProfileMetricTile("PENDING ACTIONS", activePending, const Color(0xFFE2B93B), isMobile),
                _buildProfileMetricTile("RESOLVED VERIFICATIONS", resolvedCount, Colors.lightBlueAccent, isMobile),
              ],
            ),
            SizedBox(height: isMobile ? 32 : 40),

            Text("ACCOUNT PASSPORT IDENTITY", style: _interFont(11, FontWeight.w600, color: Colors.white38, letterSpacing: 1.0)),
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 700),
              padding: EdgeInsets.all(isMobile ? 20 : 28),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF1A1A1A)),
              ),
              child: Column(
                children: [
                  _passportRow("HOLDER IDENTIFIER", "NOOR UL AIN"),
                  const Divider(color: Color(0xFF1A1A1A), height: 28),
                  _passportRow("INSTITUTIONAL EMAIL", _studentEmail),
                  const Divider(color: Color(0xFF1A1A1A), height: 28),
                  _passportRow("ROOM ALLOCATION", "WING B • ROOM 15"),
                  const Divider(color: Color(0xFF1A1A1A), height: 28),
                  _passportRow("PASSPORT KEY NODE", "HUB-SYS-$_shortUidHex"),
                  const Divider(color: Color(0xFF1A1A1A), height: 28),
                  _passportRow("AUTHORIZATION CREDENTIALS", "VERIFIED STUDENT END-USER", valueColor: const Color(0xFF99A98F)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileMetricTile(String label, int count, Color colorAccent, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _interFont(9, FontWeight.bold, color: Colors.white38, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Text(
            count.toString().padLeft(2, '0'),
            style: GoogleFonts.spaceGrotesk(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Container(width: 20, height: 2, color: colorAccent),
        ],
      ),
    );
  }

  Widget _passportRow(String label, String value, {Color valueColor = Colors.white}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: _interFont(10, FontWeight.bold, color: Colors.white38, letterSpacing: 0.5)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value.toUpperCase(), 
            textAlign: TextAlign.end,
            style: _interFont(12, FontWeight.w500, color: valueColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSectorCard(String displayTitle, String systemCategoryKey, String managedBy, String statusText, bool isOperational) {
    Color indicatorColor = isOperational ? const Color(0xFF99A98F) : const Color(0xFFE2B93B);
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () {
        setState(() {
          selectedCategory = systemCategoryKey; 
          activeNavigationIndex = 1;          
        });
      },
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF1A1A1A), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayTitle, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text("Managed by: $managedBy", style: _interFont(12, FontWeight.normal, color: Colors.white38)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 7, height: 7, decoration: BoxDecoration(color: indicatorColor, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Text(statusText, style: _interFont(12, FontWeight.w600, color: indicatorColor)),
                  ],
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white24, size: 16),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(int index, String title, IconData icon, bool isMobile) {
    bool isSelected = activeNavigationIndex == index;
    return InkWell(
      onTap: () {
        setState(() => activeNavigationIndex = index);
        if (isMobile) Get.back(); 
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        color: isSelected ? const Color(0xFF1A1A1A) : Colors.transparent,
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF99A98F) : Colors.white38, size: 20),
            const SizedBox(width: 16),
            Text(title, style: _interFont(11, isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? Colors.white : Colors.white38, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, int count, IconData icon, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 220, 
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF1A1A1A))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: _interFont(10, FontWeight.w600, color: Colors.white38, letterSpacing: 0.5)),
              Icon(icon, color: const Color(0xFF99A98F), size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Text(count.toString().padLeft(2, '0'), style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecordRow(String id, String issue, String status, Color statusColor, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: isMobile ? 12 : 24),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF1A1A1A)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(id, style: GoogleFonts.spaceGrotesk(color: const Color(0xFF99A98F), fontSize: 11, fontWeight: FontWeight.w600)),
                SizedBox(width: isMobile ? 12 : 24),
                Expanded(
                  child: Text(
                    issue, 
                    style: _interFont(isMobile ? 12 : 13, FontWeight.w400), 
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(2), border: Border.all(color: statusColor.withOpacity(0.3))),
            child: Text(status.toUpperCase(), style: _interFont(9, FontWeight.bold, color: statusColor, letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(label, style: _interFont(11, FontWeight.normal, color: Colors.white70)));
  InputDecoration _formDecoration(String hint) => InputDecoration(filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none), hintText: hint, hintStyle: const TextStyle(color: Colors.white24, fontSize: 13));
}