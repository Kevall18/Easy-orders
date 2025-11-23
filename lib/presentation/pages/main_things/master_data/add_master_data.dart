// lib/presentation/pages/master_data/add_master_data_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../core/controllers/auth_controller.dart';
import '../../../../core/controllers/master_data_controller.dart';
import '../../../../core/controllers/quality_controller.dart';
import '../../../../core/models/master_data_model.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';

class AddMasterDataPage extends StatefulWidget {
  const AddMasterDataPage({super.key});

  @override
  State<AddMasterDataPage> createState() => _AddMasterDataPageState();
}

class _AddMasterDataPageState extends State<AddMasterDataPage> {
  final _formKey = GlobalKey<FormState>();
  final _designNoController = TextEditingController();
  final _fileNameController = TextEditingController();

  int? _selectedJalu;
  String? _selectedQualityId;
  String? _selectedQualityName;

  bool _validationActivated = false;
  final MasterDataController _masterDataController = Get.find<MasterDataController>();
  final QualityController _qualityController = Get.find<QualityController>();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _qualityController.fetchQualities();
  }
  @override
  void dispose() {
    _designNoController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _validationActivated = true;
    });

    if (_formKey.currentState!.validate()) {
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

      final masterData = MasterDataModel(
        userId: _authController.user!.uid,
        designNo: _designNoController.text.trim(),
        fileName: _fileNameController.text.trim(),
        jaluNo: _selectedJalu!,
        qualityId: _selectedQualityId!,
        qualityName: _selectedQualityName!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _masterDataController.createMasterData(masterData);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Master data created successfully!'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 2),
          ),
        );
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
            duration: const Duration(seconds: 3),
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
                      child: _buildForm(themeProvider, isMobile),
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
          Text(
            'Create Master Data',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.w700,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      child: Form(
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
            const SizedBox(height: 32),
            Obx(() => _buildSubmitButton(themeProvider)),
          ],
        ),
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
          dropdownColor: themeProvider.isDarkMode
              ? Colors.grey[900]
              : Colors.white,
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

          if (qualities.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: themeProvider.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.warningColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No qualities available. Please create a quality first.',
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

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
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            dropdownColor: themeProvider.isDarkMode
                ? Colors.grey[900]
                : Colors.white,
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

  Widget _buildSubmitButton(ThemeProvider themeProvider) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _masterDataController.isLoading.value ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.6),
        ),
        child: _masterDataController.isLoading.value
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          'Create Master Data',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}