import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quality_model.dart';
import 'auth_controller.dart';

class QualityController extends GetxController {
  static QualityController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  final RxList<QualityModel> qualities = <QualityModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchQualities();
  }

  // Fetch all qualities for current user
  Future<void> fetchQualities() async {
    try {
      if (_authController.user == null) return;

      isLoading.value = true;
      errorMessage.value = '';

      final QuerySnapshot snapshot = await _firestore
          .collection('qualities')
          .where('userId', isEqualTo: _authController.user!.uid)
          .orderBy('createdAt', descending: true)
          .get();

      qualities.value = snapshot.docs
          .map((doc) => QualityModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ))
          .toList();

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to fetch qualities: ${e.toString()}';
      print('Error fetching qualities: $e');
    }
  }

  // Create new quality
  Future<bool> createQuality(QualityModel quality) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final docRef = await _firestore.collection('qualities').add(quality.toMap());

      // Add to local list
      qualities.insert(
        0,
        quality.copyWith(id: docRef.id),
      );

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to create quality: ${e.toString()}';
      print('Error creating quality: $e');
      return false;
    }
  }

  // Update existing quality
  Future<bool> updateQuality(QualityModel quality) async {
    try {
      if (quality.id == null) return false;

      isLoading.value = true;
      errorMessage.value = '';

      final updatedQuality = quality.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('qualities')
          .doc(quality.id)
          .update(updatedQuality.toMap());

      // Update local list
      final index = qualities.indexWhere((q) => q.id == quality.id);
      if (index != -1) {
        qualities[index] = updatedQuality;
      }

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to update quality: ${e.toString()}';
      print('Error updating quality: $e');
      return false;
    }
  }

  // Delete quality
  Future<bool> deleteQuality(String qualityId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firestore.collection('qualities').doc(qualityId).delete();

      // Remove from local list
      qualities.removeWhere((q) => q.id == qualityId);

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to delete quality: ${e.toString()}';
      print('Error deleting quality: $e');
      return false;
    }
  }

  // Get quality by ID from local list
  QualityModel? getQualityById(String qualityId) {
    try {
      return qualities.firstWhere((q) => q.id == qualityId);
    } catch (e) {
      return null;
    }
  }

  // ⭐ NEW: Fetch quality directly from Firebase by ID
  Future<QualityModel?> fetchQualityByIdFromFirebase(String qualityId) async {
    try {
      // First check local list
      final localQuality = getQualityById(qualityId);
      if (localQuality != null) {
        print('Quality found in local list: ${localQuality.qualityName}');
        return localQuality;
      }

      // If not in local list, fetch from Firebase
      print('Fetching quality from Firebase: $qualityId');
      final doc = await _firestore.collection('qualities').doc(qualityId).get();

      if (doc.exists) {
        final quality = QualityModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        print('Quality fetched from Firebase: ${quality.qualityName}');

        // Optionally add to local list for caching
        if (!qualities.any((q) => q.id == qualityId)) {
          qualities.add(quality);
        }

        return quality;
      } else {
        print('Quality not found in Firebase: $qualityId');
        return null;
      }
    } catch (e) {
      print('Error fetching quality from Firebase: $e');
      return null;
    }
  }

  // Get total qualities count
  int get totalQualities => qualities.length;

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  // Search qualities
  List<QualityModel> searchQualities(String query) {
    if (query.isEmpty) return qualities;

    return qualities.where((quality) {
      return quality.qualityName.toLowerCase().contains(query.toLowerCase()) ||
          quality.col1.toLowerCase().contains(query.toLowerCase()) ||
          quality.col2.toLowerCase().contains(query.toLowerCase()) ||
          quality.col3.toLowerCase().contains(query.toLowerCase()) ||
          quality.col4.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
