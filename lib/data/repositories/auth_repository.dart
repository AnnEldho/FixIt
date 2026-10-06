import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/user_model.dart';

/// Handles authentication and creation of the matching `users/{uid}` document.
class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  static bool _isDefaultAdmin(String email) =>
      email.trim().toLowerCase() == DefaultAdmin.email;

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // First ever login with the built-in admin credentials: create it.
      final missing = e.code == 'user-not-found' || e.code == 'invalid-credential';
      if (missing &&
          _isDefaultAdmin(email) &&
          password == DefaultAdmin.password) {
        await _createDefaultAdmin();
        return;
      }
      throw AppException(_authMessage(e, forLogin: true));
    } catch (_) {
      throw const AppException('Something went wrong. Please try again.');
    }
  }

  Future<void> _createDefaultAdmin() async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: DefaultAdmin.email,
        password: DefaultAdmin.password,
      );
      final user = credential.user!;

      await _db.collection(Collections.users).doc(user.uid).set(
            UserModel(
              uid: user.uid,
              name: DefaultAdmin.name,
              email: DefaultAdmin.email,
              phone: DefaultAdmin.phone,
            ).toCreateMap(asAdmin: true),
          );
      await user.updateDisplayName(DefaultAdmin.name);
    } on FirebaseAuthException catch (e) {
      // Account already exists => the password was simply wrong.
      if (e.code == 'email-already-in-use') {
        throw const AppException('Incorrect email or password.');
      }
      throw AppException(_authMessage(e, forLogin: true));
    } on FirebaseException catch (e) {
      await _auth.currentUser?.delete().catchError((_) {});
      throw AppException('Could not set up admin: ${e.message ?? e.code}');
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (_isDefaultAdmin(email)) {
      throw const AppException('This email is reserved. Use a different one.');
    }

    User? createdUser;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      createdUser = credential.user;
      if (createdUser == null) {
        throw const AppException('Unable to create user account.');
      }

      final profile = UserModel(
        uid: createdUser.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
      );

      await _db
          .collection(Collections.users)
          .doc(createdUser.uid)
          .set(profile.toCreateMap());

      await createdUser.updateDisplayName(name.trim());
    } on FirebaseAuthException catch (e) {
      throw AppException(_authMessage(e));
    } on FirebaseException catch (e) {
      // Auth account exists but the profile could not be saved: roll back so
      // the user can simply try again with the same email.
      await createdUser?.delete().catchError((_) {});
      throw AppException('Database error: ${e.message ?? e.code}');
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Something went wrong. Please try again.');
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AppException(_authMessage(e));
    } catch (_) {
      throw const AppException('Unable to send reset email.');
    }
  }

  Future<void> signOut() => _auth.signOut();

  String _authMessage(FirebaseAuthException e, {bool forLogin = false}) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Please check your internet connection.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase.';
      default:
        return forLogin
            ? 'Login failed. Please try again.'
            : 'Request failed (${e.code}).';
    }
  }
}
