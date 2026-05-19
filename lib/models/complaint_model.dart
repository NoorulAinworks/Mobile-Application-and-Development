class Complaint {
  final String id;
  final String studentId;
  final String title;
  final String description;
  final String category; // e.g., Electrical, Plumbing
  final String status;   // e.g., Pending, In-Progress, Resolved
  final DateTime createdAt;

  Complaint({
    required this.id,
    required this.studentId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
  });

  // To convert Firestore data to a Dart Object
  factory Complaint.fromMap(Map<String, dynamic> data, String documentId) {
    return Complaint(
      id: documentId,
      studentId: data['studentId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      status: data['status'] ?? 'Pending',
      createdAt: (data['createdAt'] as dynamic).toDate(),
    );
  }
}