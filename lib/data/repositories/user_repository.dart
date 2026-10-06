import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Live profile for [uid]. Emits `null` if the document does not exist yet.
  Stream<UserModel?> watchUser(String uid) {
    return _db.collection(Collections.users).doc(uid).snapshots().map(
          (doc) => doc.exists ? UserModel.fromDoc(doc) : null,
        );
  }
}
