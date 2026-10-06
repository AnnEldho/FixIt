import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';

class IssueModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String status;
  final String reportedBy;
  final String reportedByEmail;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const IssueModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.reportedBy,
    required this.reportedByEmail,
    this.createdAt,
    this.updatedAt,
  });

  factory IssueModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return IssueModel(
      id: doc.id,
      title: data['title']?.toString() ?? 'Untitled issue',
      description: data['description']?.toString() ?? '',
      category: data['category']?.toString() ?? 'Other',
      location: data['location']?.toString() ?? 'Location not provided',
      status: data['status']?.toString() ?? IssueStatus.reported,
      reportedBy: data['reportedBy']?.toString() ?? '',
      reportedByEmail: data['reportedByEmail']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
