import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ComplaintController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable loader status for form submission animation locks
  var isLoading = false.obs;

  // --- CREATE: Dispatch a New Complaint to Firestore ---
  Future<bool> createComplaint({
    required String title,
    required String description,
    required String category,
  }) async {
    if (title.trim().isEmpty || description.trim().isEmpty) {
      Get.snackbar(
        "VALIDATION ERROR",
        "All parameters must be filled before pipeline transmission.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFBA1A1A),
        colorText: Colors.white,
        borderRadius: 4,
        margin: const EdgeInsets.all(20),
      );
      return false;
    }

    try {
      isLoading.value = true;
      final User? currentUser = _auth.currentUser;
      String currentUid = currentUser?.uid ?? '';
      
      // Fast fallback resolution: Use FirebaseAuth cache profile first
      String studentName = currentUser?.displayName ?? 'Student';
      
      if (studentName == 'Student' || studentName.isEmpty) {
        try {
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUid).get();
          if (userDoc.exists) {
            studentName = (userDoc.data() as Map<String, dynamic>)['name'] ?? 'Anonymous Student';
          }
        } catch (_) {
          studentName = 'Anonymous Student';
        }
      }

      // Generate a clean professional timestamp-based reference ID tracking string
      String uniqueTicketId = "HH-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

      // Populate Firestore parameters object
      await _firestore.collection('complaints').doc(uniqueTicketId).set({
        'complaintId': uniqueTicketId,
        'uid': currentUid, // Saving under 'uid'
        'studentName': studentName,
        'category': category,
        'title': title.trim(),
        'description': description.trim(),
        'status': 'PENDING', 
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        "TICKET REGISTERED",
        "Complaint $uniqueTicketId successfully populated onto administrative ledger logs.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF99A98F),
        colorText: Colors.black,
        borderRadius: 4,
        margin: const EdgeInsets.all(20),
      );

      return true;
    } catch (e) {
      Get.snackbar(
        "TRANSACTION FAILED",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFBA1A1A),
        colorText: Colors.white,
        borderRadius: 4,
        margin: const EdgeInsets.all(20),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // --- READ: Stream real-time collection telemetry specific to the current signed-in student ---
  // ⚡ FIXED: Querying 'uid' to perfectly match the document fields and removed orderBy to prevent hiding un-timestamped data
  Stream<QuerySnapshot> streamStudentComplaints() {
    String currentUid = _auth.currentUser?.uid ?? '';
    return _firestore
        .collection('complaints')
        .where('uid', isEqualTo: currentUid) 
        .snapshots();
  }

  // --- ADMIN READ: Stream EVERY complaint logged in the system ---
  Stream<QuerySnapshot> streamAllComplaints() {
    return _firestore
        .collection('complaints')
        .snapshots();
  }

  // --- ADMIN UPDATE: Change the status machine value of a ticket ---
  Future<void> updateComplaintStatus(String ticketId, String newStatus) async {
    try {
      await _firestore.collection('complaints').doc(ticketId).update({
        'status': newStatus,
      });
      
      Get.snackbar(
        "REGISTRY UPDATED",
        "Ticket $ticketId shifted to status: $newStatus",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF99A98F),
        colorText: Colors.black,
        borderRadius: 4,
        margin: const EdgeInsets.all(20),
      );
    } catch (e) {
      Get.snackbar(
        "UPDATE FAILED",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFBA1A1A),
        colorText: Colors.white,
        borderRadius: 4,
        margin: const EdgeInsets.all(20),
      );
    }
  }

  // 🛠️ ADMIN UPDATE: Fully Update/Edit custom complaint fields inline
  Future<void> editComplaintDetails(String ticketId, String updatedTitle, String updatedCategory) async {
    try {
      await _firestore.collection('complaints').doc(ticketId).update({
        'title': updatedTitle,
        'category': updatedCategory,
      });
      Get.snackbar("Success", "Ticket parameters modified successfully.");
    } catch (e) {
      Get.snackbar("Mutation Error", e.toString());
    }
  }

  // 🛠️ ADMIN DELETE: Completely purge/delete a ticket from the database
  Future<void> deleteComplaint(String ticketId) async {
    try {
      await _firestore.collection('complaints').doc(ticketId).delete();
      Get.snackbar("Purge Complete", "Ticket $ticketId removed from active databases.");
    } catch (e) {
      Get.snackbar("Deletion Error", e.toString());
    }
  }
}