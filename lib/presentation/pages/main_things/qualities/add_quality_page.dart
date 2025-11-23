// lib/presentation/pages/qualities/add_quality_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../core/controllers/auth_controller.dart';
import '../../../../core/controllers/quality_controller.dart';
import '../../../../core/models/quality_model.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';
class AddQualityPage extends StatefulWidget {
  const AddQualityPage({super.key});

  @override
  State<AddQualityPage> createState() => _AddQualityPageState();
}

class _AddQualityPageState extends State<AddQualityPage> {
  final _formKey = GlobalKey<FormState>();
  final _qualityNameController = TextEditingController();
  final _pickController = TextEditingController();
  final _col1Controller = TextEditingController();
  final _col2Controller = TextEditingController();
  final _col3Controller = TextEditingController();
  final _col4Controller = TextEditingController();

  bool _validationActivated = false;
  final QualityController _qualityController = Get.find<QualityController>();
  final AuthController _authController = Get.find<AuthController>();

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

  Future<void> _handleSubmit() async {
    setState(() {
      _validationActivated = true;
    });

    if (_formKey.currentState!.validate()) {
      final quality = QualityModel(
        userId: _authController.user!.uid,
        qualityName: _qualityNameController.text.trim(),
        pick: int.parse(_pickController.text.trim()),
        col1: _col1Controller.text.trim(),
        col2: _col2Controller.text.trim(),
        col3: _col3Controller.text.trim(),
        col4: _col4Controller.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _qualityController.createQuality(quality);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quality created successfully!'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 2),
          ),
        );
        if (Get.previousRoute.isEmpty) {
          Get.offAllNamed('/qualities');
        } else {
          Get.back();
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_qualityController.errorMessage.value),
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
                Get.offAllNamed('/qualities');
              } else {
                Get.back();
              }
            },
          ),
          const SizedBox(width: 8),
          Text(
            'Create New Quality',
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

  Widget _buildSubmitButton(ThemeProvider themeProvider) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _qualityController.isLoading.value ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.6),
        ),
        child: _qualityController.isLoading.value
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          'Create Quality',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}