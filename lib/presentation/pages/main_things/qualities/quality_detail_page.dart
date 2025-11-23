// lib/presentation/pages/qualities/quality_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/controllers/quality_controller.dart';
import '../../../../core/models/quality_model.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';

class QualityDetailPage extends StatefulWidget {
  final String qualityId;

  const QualityDetailPage({super.key, required this.qualityId});

  @override
  State<QualityDetailPage> createState() => _QualityDetailPageState();
}

class _QualityDetailPageState extends State<QualityDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final QualityController _qualityController = Get.find<QualityController>();

  late TextEditingController _qualityNameController;
  late TextEditingController _pickController;
  late TextEditingController _col1Controller;
  late TextEditingController _col2Controller;
  late TextEditingController _col3Controller;
  late TextEditingController _col4Controller;

  bool _isEditing = false;
  bool _validationActivated = false;
  QualityModel? _quality;

  @override
  void initState() {
    super.initState();
    _loadQuality();

    // If quality not found (e.g., after reload), fetch from Firebase
    if (_quality == null) {
      _fetchQualityFromFirebase();
    }
  }

  void _loadQuality() {
    _quality = _qualityController.getQualityById(widget.qualityId);
    if (_quality != null) {
      _qualityNameController = TextEditingController(text: _quality!.qualityName);
      _pickController = TextEditingController(text: _quality!.pick.toString());
      _col1Controller = TextEditingController(text: _quality!.col1);
      _col2Controller = TextEditingController(text: _quality!.col2);
      _col3Controller = TextEditingController(text: _quality!.col3);
      _col4Controller = TextEditingController(text: _quality!.col4);
    }
  }

  Future<void> _fetchQualityFromFirebase() async {
    try {
      await _qualityController.fetchQualities();
      setState(() {
        _quality = _qualityController.getQualityById(widget.qualityId);
        if (_quality != null) {
          _qualityNameController = TextEditingController(text: _quality!.qualityName);
          _pickController = TextEditingController(text: _quality!.pick.toString());
          _col1Controller = TextEditingController(text: _quality!.col1);
          _col2Controller = TextEditingController(text: _quality!.col2);
          _col3Controller = TextEditingController(text: _quality!.col3);
          _col4Controller = TextEditingController(text: _quality!.col4);
        }
      });
    } catch (e) {
      print('Error fetching quality: $e');
    }
  }

  @override
  void dispose() {
    _qualityNameController.dispose();
    _pickController.dispose();
    _col1Controller.dispose();
    _col2Controller.dispose();
    _col3Controller.dispose();
    _col4Controller.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    setState(() {
      _validationActivated = true;
    });

    if (_formKey.currentState!.validate() && _quality != null) {
      final updatedQuality = _quality!.copyWith(
        qualityName: _qualityNameController.text.trim(),
        pick: int.parse(_pickController.text.trim()),
        col1: _col1Controller.text.trim(),
        col2: _col2Controller.text.trim(),
        col3: _col3Controller.text.trim(),
        col4: _col4Controller.text.trim(),
      );

      final success = await _qualityController.updateQuality(updatedQuality);

      if (success && mounted) {
        setState(() {
          _isEditing = false;
          _quality = updatedQuality;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quality updated successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_qualityController.errorMessage.value),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Quality'),
        content: Text(
            'Are you sure you want to delete "${_quality!.qualityName}"? This action cannot be undone.'),
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

    if (shouldDelete == true && _quality?.id != null) {
      final success = await _qualityController.deleteQuality(_quality!.id!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quality deleted successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Get.back(); // Go back to list
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_qualityController.errorMessage.value),
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

    if (_quality == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Quality not found',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
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
                Get.offAllNamed('/qualities');
              } else {
                Get.back();
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Quality Details',
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
              tooltip: 'Edit Quality',
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: AppTheme.errorColor),
              onPressed: _confirmDelete,
              tooltip: 'Delete Quality',
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
        _buildDetailRow('Quality Name', _quality!.qualityName, themeProvider),
        const Divider(height: 32),
        _buildDetailRow('Pick', _quality!.pick.toString(), themeProvider),
        const Divider(height: 32),
        _buildDetailRow('Column 1', _quality!.col1, themeProvider),
        const Divider(height: 32),
        _buildDetailRow('Column 2', _quality!.col2, themeProvider),
        const Divider(height: 32),
        _buildDetailRow('Column 3', _quality!.col3, themeProvider),
        const Divider(height: 32),
        _buildDetailRow('Column 4', _quality!.col4, themeProvider),
        const Divider(height: 32),
        _buildDetailRow(
          'Created',
          DateFormat('MMM dd, yyyy hh:mm a').format(_quality!.createdAt),
          themeProvider,
        ),
        const Divider(height: 32),
        _buildDetailRow(
          'Last Updated',
          DateFormat('MMM dd, yyyy hh:mm a').format(_quality!.updatedAt),
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

  Widget _buildEditForm(ThemeProvider themeProvider, bool isMobile) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _qualityNameController,
            label: 'Quality Name',
            hint: 'Enter quality name',
            icon: Icons.label_rounded,
            themeProvider: themeProvider,
            validator: (value) {
              if (!_validationActivated) return null;
              if (value == null || value.trim().isEmpty) {
                return 'Please enter quality name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _pickController,
            label: 'Pick',
            hint: 'Enter pick value',
            icon: Icons.pin_rounded,
            themeProvider: themeProvider,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (!_validationActivated) return null;
              if (value == null || value.trim().isEmpty) {
                return 'Please enter pick value';
              }
              if (int.tryParse(value.trim()) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _col1Controller,
            label: 'Column 1',
            hint: 'Enter column 1 value',
            icon: Icons.view_column_rounded,
            themeProvider: themeProvider,
            validator: (value) {
              if (!_validationActivated) return null;
              if (value == null || value.trim().isEmpty) {
                return 'Please enter column 1 value';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _col2Controller,
            label: 'Column 2',
            hint: 'Enter column 2 value',
            icon: Icons.view_column_rounded,
            themeProvider: themeProvider,
            validator: (value) {
              if (!_validationActivated) return null;
              if (value == null || value.trim().isEmpty) {
                return 'Please enter column 2 value';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _col3Controller,
            label: 'Column 3',
            hint: 'Enter column 3 value',
            icon: Icons.view_column_rounded,
            themeProvider: themeProvider,
            validator: (value) {
              if (!_validationActivated) return null;
              if (value == null || value.trim().isEmpty) {
                return 'Please enter column 3 value';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _col4Controller,
            label: 'Column 4',
            hint: 'Enter column 4 value',
            icon: Icons.view_column_rounded,
            themeProvider: themeProvider,
            validator: (value) {
              if (!_validationActivated) return null;
              if (value == null || value.trim().isEmpty) {
                return 'Please enter column 4 value';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _validationActivated = false;
                      _loadQuality();
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
                  _qualityController.isLoading.value ? null : _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _qualityController.isLoading.value
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
    TextInputType? keyboardType,
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
          keyboardType: keyboardType,
          validator: validator,
          inputFormatters: keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
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
}