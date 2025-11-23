import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/master_data_model.dart';
import '../models/quality_model.dart';
import 'auth_controller.dart';
import 'quality_controller.dart';

class MasterDataController extends GetxController {
  static MasterDataController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  final QualityController _qualityController = Get.find<QualityController>();

  final RxList<MasterDataModel> masterDataList = <MasterDataModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMasterData();
  }

  // Fetch all master data for current user
  Future<void> fetchMasterData() async {
    try {
      if (_authController.user == null) return;

      isLoading.value = true;
      errorMessage.value = '';

      final QuerySnapshot snapshot = await _firestore
          .collection('masterData')
          .where('userId', isEqualTo: _authController.user!.uid)
          .orderBy('createdAt', descending: true)
          .get();

      masterDataList.value = snapshot.docs
          .map((doc) => MasterDataModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ))
          .toList();

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to fetch master data: ${e.toString()}';
      print('Error fetching master data: $e');
    }
  }

  // Create new master data
  Future<bool> createMasterData(MasterDataModel masterData) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final docRef = await _firestore.collection('masterData').add(masterData.toMap());

      // Add to local list
      masterDataList.insert(
        0,
        masterData.copyWith(id: docRef.id),
      );

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to create master data: ${e.toString()}';
      print('Error creating master data: $e');
      return false;
    }
  }

  // Update existing master data
  Future<bool> updateMasterData(MasterDataModel masterData) async {
    try {
      if (masterData.id == null) return false;

      isLoading.value = true;
      errorMessage.value = '';

      final updatedMasterData = masterData.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('masterData')
          .doc(masterData.id)
          .update(updatedMasterData.toMap());

      // Update local list
      final index = masterDataList.indexWhere((m) => m.id == masterData.id);
      if (index != -1) {
        masterDataList[index] = updatedMasterData;
      }

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to update master data: ${e.toString()}';
      print('Error updating master data: $e');
      return false;
    }
  }

  // Delete master data
  Future<bool> deleteMasterData(String masterDataId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firestore.collection('masterData').doc(masterDataId).delete();

      // Remove from local list
      masterDataList.removeWhere((m) => m.id == masterDataId);

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to delete master data: ${e.toString()}';
      print('Error deleting master data: $e');
      return false;
    }
  }

  // Get master data by ID from local list
  MasterDataModel? getMasterDataById(String masterDataId) {
    try {
      return masterDataList.firstWhere((m) => m.id == masterDataId);
    } catch (e) {
      return null;
    }
  }

  // ⭐ NEW: Fetch master data directly from Firebase by ID
  Future<MasterDataModel?> fetchMasterDataByIdFromFirebase(String masterDataId) async {
    try {
      // First check local list
      final localMasterData = getMasterDataById(masterDataId);
      if (localMasterData != null) {
        print('MasterData found in local list: ${localMasterData.designNo}');
        return localMasterData;
      }

      // If not in local list, fetch from Firebase
      print('Fetching master data from Firebase: $masterDataId');
      final doc = await _firestore.collection('masterData').doc(masterDataId).get();

      if (doc.exists) {
        final masterData = MasterDataModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        print('MasterData fetched from Firebase: ${masterData.designNo}');

        // Optionally add to local list for caching
        if (!masterDataList.any((m) => m.id == masterDataId)) {
          masterDataList.add(masterData);
        }

        return masterData;
      } else {
        print('MasterData not found in Firebase: $masterDataId');
        return null;
      }
    } catch (e) {
      print('Error fetching master data from Firebase: $e');
      return null;
    }
  }

  // Get quality name by ID (with fallback to stored name)
  String getQualityName(String qualityId, String fallbackName) {
    try {
      final quality = _qualityController.getQualityById(qualityId);
      return quality?.qualityName ?? fallbackName;
    } catch (e) {
      return fallbackName;
    }
  }

  // Get quality by ID
  QualityModel? getQualityById(String qualityId) {
    return _qualityController.getQualityById(qualityId);
  }

  // Get total master data count
  int get totalMasterData => masterDataList.length;

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  // Search master data
  List<MasterDataModel> searchMasterData(String query) {
    if (query.isEmpty) return masterDataList;

    return masterDataList.where((masterData) {
      return masterData.designNo.toLowerCase().contains(query.toLowerCase()) ||
          masterData.fileName.toLowerCase().contains(query.toLowerCase()) ||
          masterData.qualityName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Get master data by jalu
  List<MasterDataModel> getMasterDataByJalu(int jaluNo) {
    return masterDataList.where((m) => m.jaluNo == jaluNo).toList();
  }

  // Get master data by quality
  List<MasterDataModel> getMasterDataByQuality(String qualityId) {
    return masterDataList.where((m) => m.qualityId == qualityId).toList();
  }
}