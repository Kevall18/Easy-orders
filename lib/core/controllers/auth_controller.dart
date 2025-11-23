import 'package:easy_orders/core/models/user_model.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final Box _box;

  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> firestoreUser = Rx<UserModel?>(null);

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  User? get user => _firebaseUser.value;
  bool get isLoggedIn => _firebaseUser.value != null;

  @override
  void onInit() {
    super.onInit();
    _initHive();
    _firebaseUser.bindStream(_auth.authStateChanges());
    ever(_firebaseUser, _handleAuthChanged);
  }

  Future<void> _handleAuthChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      await _fetchFirestoreUser(firebaseUser.uid);
    } else {
      firestoreUser.value = null;
    }
  }

  Future<void> _fetchFirestoreUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        firestoreUser.value = UserModel.fromSnapshot(doc);
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch user data: $e';
    }
  }

  Future<void> _initHive() async {
    _box = Hive.box('settings');
  }

  // NEW: Update user profile
  Future<bool> updateUserProfile({
    String? name,
    int? programDays,
  }) async {
    try {
      if (_firebaseUser.value == null) return false;

      isLoading.value = true;
      errorMessage.value = '';

      final uid = _firebaseUser.value!.uid;
      final updates = <String, dynamic>{};

      if (name != null && name.isNotEmpty) {
        updates['name'] = name;
        await _firebaseUser.value!.updateDisplayName(name);
      }

      if (programDays != null) {
        updates['programDays'] = programDays;
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updates);
        await _fetchFirestoreUser(uid); // Refresh local data
      }

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to update profile: $e';
      return false;
    }
  }

  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      isLoading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      errorMessage.value = _getErrorMessage(e.code);
      return false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'An unexpected error occurred';
      return false;
    }
  }

  Future<bool> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();
      _firebaseUser.value = _auth.currentUser;

      User? newUser = _firebaseUser.value;
      if (newUser != null) {
        final userModel = UserModel(
          uid: newUser.uid,
          name: name,
          email: email.trim(),
          programDays: 0,
          createdAt: null,
        );

        await _firestore
            .collection('users')
            .doc(newUser.uid)
            .set(userModel.toJson());

        firestoreUser.value = userModel;
      }

      isLoading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      errorMessage.value = _getErrorMessage(e.code);
      return false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'An unexpected error occurred';
      return false;
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _auth.sendPasswordResetEmail(email: email.trim());

      isLoading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      errorMessage.value = _getErrorMessage(e.code);
      return false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'An unexpected error occurred';
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      errorMessage.value = 'Failed to sign out';
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Invalid password';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      default:
        return 'Authentication failed. Please try again';
    }
  }

  void clearError() {
    errorMessage.value = '';
  }
}