import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/issue_model.dart';

class IssueRepository {
  IssueRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _issues =>
      _db.collection(Collections.issues);

  /// Issues reported by [uid], newest first.
  /// Sorted on the device so no composite Firestore index is required.
  Stream<List<IssueModel>> watchUserIssues(String uid) {
    return _issues.where('reportedBy', isEqualTo: uid).snapshots().map((snap) {
      final list = snap.docs.map(IssueModel.fromDoc).toList();
      list.sort(_newestFirst);
      return list;
    });
  }

  /// Every issue (admin view), newest first.
  Stream<List<IssueModel>> watchAllIssues() {
    return _issues.snapshots().map((snap) {
      final list = snap.docs.map(IssueModel.fromDoc).toList();
      list.sort(_newestFirst);
      return list;
    });
  }

  Stream<IssueModel?> watchIssue(String id) {
    return _issues
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? IssueModel.fromDoc(doc) : null);
  }

  Future<void> createIssue({
    required User reporter,
    required String title,
    required String description,
    required String category,
    required String location,
  }) async {
    try {
      await _issues.add({
        'title': title.trim(),
        'description': description.trim(),
        'category': category,
        'location': location.trim(),
        'status': IssueStatus.reported,
        'reportedBy': reporter.uid,
        'reportedByEmail': reporter.email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw AppException('Could not submit issue: ${e.message ?? e.code}');
    }
  }

  /// Admin only (enforced by Firestore security rules).
  Future<void> updateStatus(String issueId, String status) async {
    try {
      await _issues.doc(issueId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw AppException('Could not update status: ${e.message ?? e.code}');
    }
  }

  static int _newestFirst(IssueModel a, IssueModel b) {
    final aTime = a.createdAt;
    final bTime = b.createdAt;
    if (aTime == null && bTime == null) return 0;
    if (aTime == null) return -1; // pending server timestamp = newest
    if (bTime == null) return 1;
    return bTime.compareTo(aTime);
  }
}
