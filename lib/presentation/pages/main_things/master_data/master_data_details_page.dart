// lib/presentation/pages/master_data/master_data_detail_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/controllers/master_data_controller.dart';
import '../../../../core/controllers/quality_controller.dart';
import '../../../../core/models/master_data_model.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';
class MasterDataDetailPage extends StatefulWidget {
  final String masterDataId;

  const MasterDataDetailPage({super.key, required this.masterDataId});

  @override
  State<MasterDataDetailPage> createState() => _MasterDataDetailPageState();
}

class _MasterDataDetailPageState extends State<MasterDataDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final MasterDataController _masterDataController = Get.find<MasterDataController>();
  final QualityController _qualityController = Get.find<QualityController>();

  late TextEditingController _designNoController;
  late TextEditingController _fileNameController;
  int? _selectedJalu;
  String? _selectedQualityId;
  String? _selectedQualityName;

  bool _isEditing = false;
  bool _validationActivated = false;
  MasterDataModel? _masterData;

  @override
  void initState() {
    super.initState();
    _loadMasterData();

    // If master data not found (e.g., after reload), fetch from Firebase
    if (_masterData == null) {
      _fetchMasterDataFromFirebase();
    }
  }

  void _loadMasterData() {
    _masterData = _masterDataController.getMasterDataById(widget.masterDataId);
    if (_masterData != null) {
      _designNoController = TextEditingController(text: _masterData!.designNo);
      _fileNameController = TextEditingController(text: _masterData!.fileName);
      _selectedJalu = _masterData!.jaluNo;
      _selectedQualityId = _masterData!.qualityId;
      _selectedQualityName = _masterData!.qualityName;
    }
  }

  Future<void> _fetchMasterDataFromFirebase() async {
    try {
      await _masterDataController.fetchMasterData();
      setState(() {
        _masterData = _masterDataController.getMasterDataById(widget.masterDataId);
        if (_masterData != null) {
          _designNoController = TextEditingController(text: _masterData!.designNo);
          _fileNameController = TextEditingController(text: _masterData!.fileName);
          _selectedJalu = _masterData!.jaluNo;
          _selectedQualityId = _masterData!.qualityId;
          _selectedQualityName = _masterData!.qualityName;
        }
      });
    } catch (e) {
      print('Error fetching master data: $e');
    }
  }

  @override
  void dispose() {
    _designNoController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    setState(() {
      _validationActivated = true;
    });

    if (_formKey.currentState!.validate() && _masterData != null) {
      if (_selectedJalu == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a Jalu'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      if (_selectedQualityId == null || _selectedQualityName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a Quality'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      final updatedMasterData = _masterData!.copyWith(
        designNo: _designNoController.text.trim(),
        fileName: _fileNameController.text.trim(),
        jaluNo: _selectedJalu!,
        qualityId: _selectedQualityId!,
        qualityName: _selectedQualityName!,
      );

      final success = await _masterDataController.updateMasterData(updatedMasterData);

      if (success && mounted) {
        setState(() {
          _isEditing = false;
          _masterData = updatedMasterData;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Master data updated successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_masterDataController.errorMessage.value),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Master Data'),
        content: Text(
            'Are you sure you want to delete "${_masterData!.designNo}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && _masterData?.id != null) {
      final success = await _masterDataController.deleteMasterData(_masterData!.id!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Master data deleted successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        // Navigate back to master data list
        if (Get.previousRoute.isEmpty) {
          Get.offAllNamed('/master-data');
        } else {
          Get.back();
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_masterDataController.errorMessage.value),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    if (_masterData == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: themeProvider.isDarkMode
                ? AppTheme.darkBackgroundGradient
                : AppTheme.backgroundGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading master data...',
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.isDarkMode
              ? AppTheme.darkBackgroundGradient
              : AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(themeProvider, isMobile),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: _buildDetailsCard(themeProvider, isMobile),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.7),
        border: Border(
          bottom: BorderSide(
            color: themeProvider.isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              if (Get.previousRoute.isEmpty) {
                Get.offAllNamed('/master-data');
              } else {
                Get.back();
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Master Data Details',
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.w700,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppTheme.primaryColor),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: 'Edit Master Data',
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: AppTheme.errorColor),
              onPressed: _confirmDelete,
              tooltip: 'Delete Master Data',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsCard(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: _isEditing
          ? _buildEditForm(themeProvider, isMobile)
          : _buildViewDetails(themeProvider),
    );
  }

  Widget _buildViewDetails(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Design Number', _masterData!.designNo, themeProvider),
        const Divider(height: 32),
        _buildDetailRow('File Name', _masterData!.fileName, themeProvider),
        const Divider(height: 32),
        _buildDetailRow('Jalu', _masterData!.jaluDisplayName, themeProvider),
        const Divider(height: 32),
        _buildDetailRow(
          'Quality',
          _masterDataController.getQualityName(
            _masterData!.qualityId,
            _masterData!.qualityName,
          ),
          themeProvider,
        ),
        const Divider(height: 32),
        _buildDetailRow(
          'Created',
          DateFormat('MMM dd, yyyy hh:mm a').format(_masterData!.createdAt),
          themeProvider,
        ),
        const Divider(height: 32),
        _buildDetailRow(
          'Last Updated',
          DateFormat('MMM dd, yyyy hh:mm a').format(_masterData!.updatedAt),
          themeProvider,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeProvider themeProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // Continue in next part...
  Widget _buildEditForm(ThemeProvider themeProvider, bool isMobile) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _designNoController,
            label: 'Design Number',
            hint: 'Enter design number',
            icon: Icons.design_services_rounded,
            themeProvider: themeProvider,
            validator: (value) {
              if (!_validationActivated) return null;
              if (value == null || value.trim().isEmpty) {
                return 'Please enter design number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _fileNameController,
            label: 'File Name',
            hint: 'Enter file name',
            icon: Icons.description_rounded,
            themeProvider: themeProvider,
            validator: (value) {
              if (!_validationActivated) return null;
              if (value == null || value.trim().isEmpty) {
                return 'Please enter file name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildJaluDropdown(themeProvider),
          const SizedBox(height: 20),
          _buildQualityDropdown(themeProvider),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _validationActivated = false;
                      _loadMasterData();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.errorColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => ElevatedButton(
                  onPressed:
                  _masterDataController.isLoading.value ? null : _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _masterDataController.isLoading.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Save Changes'),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeProvider themeProvider,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white38 : Colors.black38,
            ),
            prefixIcon: Icon(
              icon,
              color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
            ),
            filled: true,
            fillColor: themeProvider.isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJaluDropdown(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Jalu',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _selectedJalu,
          decoration: InputDecoration(
            hintText: 'Select jalu number',
            hintStyle: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white38 : Colors.black38,
            ),
            prefixIcon: Icon(
              Icons.category_rounded,
              color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
            ),
            filled: true,
            fillColor: themeProvider.isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
          dropdownColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
          items: MasterDataModel.availableJaluOptions.map((jalu) {
            return DropdownMenuItem<int>(
              value: jalu,
              child: Text('Jalu $jalu'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedJalu = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildQualityDropdown(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Quality',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final qualities = _qualityController.qualities;

          return DropdownButtonFormField<String>(
            value: _selectedQualityId,
            decoration: InputDecoration(
              hintText: 'Select quality',
              hintStyle: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white38 : Colors.black38,
              ),
              prefixIcon: Icon(
                Icons.star_rounded,
                color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
              ),
              filled: true,
              fillColor: themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            dropdownColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
            items: qualities.map((quality) {
              return DropdownMenuItem<String>(
                value: quality.id,
                child: Text(quality.qualityName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedQualityId = value;
                _selectedQualityName = qualities
                    .firstWhere((q) => q.id == value)
                    .qualityName;
              });
            },
          );
        }),
      ],
    );
  }
}