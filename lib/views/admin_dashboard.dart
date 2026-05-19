import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'dart:math' as math;

import '../controllers/complaint_controller.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with TickerProviderStateMixin {
  late final ComplaintController _complaintController;
  // FIX A: Keep stream persistent so rebuilding tabs doesn't reset DB connection cost
  late final Stream<QuerySnapshot> _complaintsStream; 
  int activeNavigationIndex = 0;

  @override
  void initState() {
    super.initState();
    _complaintController = Get.isRegistered<ComplaintController>()
        ? Get.find<ComplaintController>()
        : Get.put(ComplaintController());
        
    _complaintsStream = FirebaseFirestore.instance.collection('complaints').snapshots();
  }

  TextStyle _interFont(double size, FontWeight weight, {Color color = Colors.white, double letterSpacing = 0.0}) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  // ================= LIVE INTERACTIVE CRUD EDIT MODAL =================
  void _showEditComplaintDialog(String docId, Map<String, dynamic> currentData) {
    final titleController = TextEditingController(text: currentData['title'] ?? '');
    final roomController = TextEditingController(text: currentData['roomNo'] ?? '');
    
    // Normalized casing lookup
    String selectedCategory = currentData['category'] ?? 'Electricity';
    final categories = ['Electricity', 'Internet & Wi-Fi', 'Plumbing & Water', 'Housekeeping'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111111),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF1A1A1A)),
          ),
          title: Text(
            "EDIT COMPLAINT ENTRY",
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("COMPLAINT TITLE", style: _interFont(10, FontWeight.w600, color: Colors.white38)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      style: _interFont(13, FontWeight.w400, color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF161616),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF222222)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("ROOM NUMBER", style: _interFont(10, FontWeight.w600, color: Colors.white38)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: roomController,
                      style: _interFont(13, FontWeight.w400, color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF161616),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF222222)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("SECTOR CATEGORY", style: _interFont(10, FontWeight.w600, color: Colors.white38)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF222222)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          // FIX B: Robust validation backup so dropdown engine never crashes on value mismatch
                          value: categories.contains(selectedCategory) ? selectedCategory : categories.first,
                          dropdownColor: const Color(0xFF111111),
                          isExpanded: true,
                          style: _interFont(13, FontWeight.w400, color: Colors.white),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white38),
                          items: categories.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setModalState(() {
                                selectedCategory = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("CANCEL", style: _interFont(11, FontWeight.bold, color: Colors.white38)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('complaints')
                      .doc(docId)
                      .update({
                    'title': titleController.text.trim(),
                    'roomNo': roomController.text.trim(),
                    'category': selectedCategory,
                  });
                  
                  if (context.mounted) Navigator.pop(context);
                  Get.snackbar(
                    "DATABASE UPDATED", 
                    "Complaint entry synced successfully.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF151515),
                    colorText: Colors.greenAccent,
                  );
                } catch (e) {
                  Get.snackbar("ERROR", "Failed to update: $e", backgroundColor: Colors.redAccent);
                }
              },
              child: Text("SAVE CHANGES", style: _interFont(11, FontWeight.bold, color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // ================= MAIN INTERFACE BUILD ENGINE =================
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        return Scaffold(
          backgroundColor: const Color(0xFF070707),
          appBar: isMobile
              ? AppBar(
                  backgroundColor: const Color(0xFF0F0F0F),
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: Text(
                    "HOSTELHUB ADMIN",
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          drawer: isMobile
              ? Drawer(
                  backgroundColor: const Color(0xFF0F0F0F),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      _buildSidebarItem(0, "GLOBAL OVERVIEW", Icons.analytics_outlined),
                      _buildSidebarItem(1, "SECTOR OVERSEE", Icons.layers_outlined),
                      const Spacer(),
                      _buildSidebarItem(2, "TERMINATE SESSION", Icons.power_settings_new_outlined),
                      const SizedBox(height: 20),
                    ],
                  ),
                )
              : null,
          body: Row(
            children: [
              if (!isMobile)
                Container(
                  width: 260,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F0F0F),
                    border: Border(right: BorderSide(color: Color(0xFF161616))),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildSidebarItem(0, "GLOBAL OVERVIEW", Icons.analytics_outlined),
                      _buildSidebarItem(1, "SECTOR OVERSEE", Icons.layers_outlined),
                      const Spacer(),
                      _buildSidebarItem(2, "TERMINATE SESSION", Icons.power_settings_new_outlined),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 14 : 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 25),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _complaintsStream, // FIX A: Implemented assigned stream pointer reference
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator(color: Colors.lightBlueAccent));
                            }
                            
                            final docs = snapshot.data?.docs ?? [];
                            
                            return CustomScrollView(
                              physics: const BouncingScrollPhysics(),
                              slivers: [
                                if (activeNavigationIndex == 0) ...[
                                  _buildGlobalOverviewTab(docs, isMobile),
                                  _buildComplaintsSliverList(docs, isMobile),
                                ] else ...[
                                  _buildSectorOverseeTab(docs, isMobile),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    if (activeNavigationIndex == 2) return const SizedBox.shrink();
    return Text(
      activeNavigationIndex == 0 ? "ADMINISTRATIVE CENTRAL CONSOLE" : "SECTOR OVERSIGHT CORE",
      style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w400),
    );
  }

  Widget _buildGlobalOverviewTab(List<QueryDocumentSnapshot> docs, bool isMobile) {
    int total = docs.length;
    int pending = docs.where((d) => (d.data() as Map)['status'].toString().toUpperCase() != 'RESOLVED').length;
    int resolved = docs.where((d) => (d.data() as Map)['status'].toString().toUpperCase() == 'RESOLVED').length;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _metricCard("TOTAL", total, isMobile),
              _metricCard("PENDING", pending, isMobile),
              _metricCard("RESOLVED", resolved, isMobile),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            "ALL COMPLAINTS SUBMISSIONS",
            style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _metricCard(String title, int value, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 250,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _interFont(10, FontWeight.w600, color: Colors.white38)),
          const SizedBox(height: 12),
          Text("$value", style: GoogleFonts.spaceGrotesk(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectorOverseeTab(List<QueryDocumentSnapshot> docs, bool isMobile) {
    int count(String key) => docs.where((d) => (d.data() as Map)['category'].toString().toLowerCase() == key.toLowerCase()).length;
    int countPending(String key) => docs.where((d) {
          final data = d.data() as Map;
          return data['category'].toString().toLowerCase() == key.toLowerCase() &&
              data['status'].toString().toUpperCase() != 'RESOLVED';
        }).length;

    return SliverToBoxAdapter(
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: isMobile ? WrapAlignment.start : WrapAlignment.center,
        children: [
          NativeFlippableCard(title: "ELECTRICITY CORE", systemKey: "Electricity", manager: "Warden A", total: count("Electricity"), pending: countPending("Electricity"), isMobile: isMobile),
          NativeFlippableCard(title: "INTERNET", systemKey: "Internet & Wi-Fi", manager: "IT Desk", total: count("Internet & Wi-Fi"), pending: countPending("Internet & Wi-Fi"), isMobile: isMobile),
          NativeFlippableCard(title: "PLUMBING", systemKey: "Plumbing & Water", manager: "Wing B", total: count("Plumbing & Water"), pending: countPending("Plumbing & Water"), isMobile: isMobile),
          NativeFlippableCard(title: "HOUSEKEEPING", systemKey: "Housekeeping", manager: "Janitorial", total: count("Housekeeping"), pending: countPending("Housekeeping"), isMobile: isMobile),
        ],
      ),
    );
  }

  Widget _buildComplaintsSliverList(List<QueryDocumentSnapshot> docs, bool isMobile) {
    if (docs.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(6)),
          child: Center(child: Text("No active entries found.", style: _interFont(13, FontWeight.w400, color: Colors.white38))),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final doc = docs[index];
          final data = doc.data() as Map<String, dynamic>;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ComplaintCardItem(
              docId: doc.id,
              data: data,
              interFont: _interFont,
              onEdit: () => _showEditComplaintDialog(doc.id, data),
              complaintController: _complaintController,
            ),
          );
        },
        childCount: docs.length,
      ),
    );
  }

  Widget _buildSidebarItem(int index, String title, IconData icon) {
    bool selected = activeNavigationIndex == index;
    bool isLogout = index == 2;

    return InkWell(
      onTap: () async {
        if (isLogout) {
          if (MediaQuery.of(context).size.width < 800) Navigator.pop(context);
          
          try {
            await firebase_auth.FirebaseAuth.instance.signOut();
            // FIX C: Safe implementation instead of wipe-all to cleanly switch state views
            Get.offAllNamed('/');
          } catch (e) {
            Get.snackbar("LOGOUT ERROR", "Failed to clear session safely.");
          }
          return;
        }
        setState(() => activeNavigationIndex = index);
        if (MediaQuery.of(context).size.width < 800) Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        color: selected && !isLogout ? const Color(0xFF151515) : Colors.transparent,
        child: Row(
          children: [
            Icon(icon, color: isLogout ? Colors.redAccent : (selected ? Colors.white : Colors.white38)),
            const SizedBox(width: 12),
            Text(title, style: _interFont(11, FontWeight.w600, color: isLogout ? Colors.redAccent : (selected ? Colors.white : Colors.white38))),
          ],
        ),
      ),
    );
  }
}

// ================= ISOLATED COMPLAINT CARD ELEMENT =================
class ComplaintCardItem extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final TextStyle Function(double, FontWeight, {Color color, double letterSpacing}) interFont;
  final VoidCallback onEdit;
  final ComplaintController complaintController;

  const ComplaintCardItem({
    super.key,
    required this.docId,
    required this.data,
    required this.interFont,
    required this.onEdit,
    required this.complaintController,
  });

  @override
  Widget build(BuildContext context) {
    final String status = (data['status'] ?? 'PENDING').toString().toUpperCase();
    final bool isResolved = status == 'RESOLVED';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((data['title'] ?? 'No Title').toString().toUpperCase(), style: interFont(13, FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text("Category: ${data['category'] ?? 'General'} • Room: ${data['roomNo'] ?? 'N/A'}", style: interFont(11, FontWeight.w400, color: Colors.white38)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_note_outlined, color: Colors.lightBlueAccent, size: 22),
                onPressed: onEdit,
              ),
              if (!isResolved)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 20),
                  onPressed: () => complaintController.updateComplaintStatus(docId, "RESOLVED"),
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => complaintController.deleteComplaint(docId),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// ================= NATIVE FLIP CARDS CONTAINER (OPTIMIZED) =================
class NativeFlippableCard extends StatefulWidget {
  final String title;
  final String systemKey;
  final String manager;
  final int total;
  final int pending;
  final bool isMobile;

  const NativeFlippableCard({
    super.key,
    required this.title,
    required this.systemKey,
    required this.manager,
    required this.total,
    required this.pending,
    required this.isMobile,
  });

  @override
  State<NativeFlippableCard> createState() => _NativeFlippableCardState();
}

class _NativeFlippableCardState extends State<NativeFlippableCard> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _animation;
  bool isFrontSide = true;

  void _animationListener() {
    final side = _flipController.value < 0.5;
    if (side != isFrontSide) {
      setState(() {
        isFrontSide = side;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_flipController)..addListener(_animationListener);
  }

  @override
  void dispose() {
    // FIX D: Cleanly unmount listener pointers to prevent animation profile frame leaking 
    _animation.removeListener(_animationListener);
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cardConstraints) {
        final double maxCardWidth = widget.isMobile ? (cardConstraints.maxWidth > 0 ? cardConstraints.maxWidth : 330.0) : 330.0;

        return GestureDetector(
          onTap: () => _flipController.isCompleted ? _flipController.reverse() : _flipController.forward(),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final double transformRotationValue = _animation.value * math.pi;
              return Transform(
                transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(transformRotationValue),
                alignment: Alignment.center,
                child: isFrontSide 
                    ? _front(maxCardWidth) 
                    : Transform(
                        transform: Matrix4.identity()..rotateY(math.pi),
                        alignment: Alignment.center,
                        child: _back(maxCardWidth),
                      ),
              );
            },
          ),
        );
      }
    );
  }

  Widget _front(double cardWidth) {
    return Container(
      width: cardWidth,
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text("Supervisor: ${widget.manager}", style: const TextStyle(color: Colors.white38, fontSize: 13)),
          Text(widget.pending > 0 ? "${widget.pending} ACTIVE" : "OK", style: TextStyle(color: widget.pending > 0 ? Colors.orangeAccent : Colors.greenAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _back(double cardWidth) {
    return Container(
      width: cardWidth,
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("TOTAL REQUESTS: ${widget.total}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text("PENDING ACTIVE: ${widget.pending}", style: const TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }
}