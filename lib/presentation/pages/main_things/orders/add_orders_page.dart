// lib/presentation/pages/orders/add_order_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../core/controllers/auth_controller.dart';
import '../../../../core/controllers/master_data_controller.dart';
import '../../../../core/controllers/order_controller.dart';
import '../../../../core/models/master_data_model.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/dialogue_box/master_data_dialogue_box.dart';

class AddOrderPage extends StatefulWidget {
  const AddOrderPage({super.key});

  @override
  State<AddOrderPage> createState() => _AddOrderPageState();
}

class _AddOrderPageState extends State<AddOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _partyNameController = TextEditingController();
  final _notesController = TextEditingController();

  final List<OrderItemInput> _orderItems = [];

  bool _validationActivated = false;
  final OrderController _orderController = Get.find<OrderController>();
  final MasterDataController _masterDataController = Get.find<MasterDataController>();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _masterDataController.fetchMasterData();
    _addOrderItem();
  }

  @override
  void dispose() {
    _partyNameController.dispose();
    _notesController.dispose();
    for (var item in _orderItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _addOrderItem() {
    setState(() {
      _orderItems.add(OrderItemInput());
    });
  }

  void _removeOrderItem(int index) {
    if (_orderItems.length > 1) {
      setState(() {
        _orderItems[index].dispose();
        _orderItems.removeAt(index);
      });
    }
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _validationActivated = true;
    });

    if (!_formKey.currentState!.validate()) return;

    for (var i = 0; i < _orderItems.length; i++) {
      if (_orderItems[i].selectedMasterData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select master data for item ${i + 1}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      if (_orderItems[i].pcsController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter pieces for item ${i + 1}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
    }

    final items = _orderItems.map((itemInput) {
      final masterData = itemInput.selectedMasterData!;
      return OrderItem(
        pcs: int.parse(itemInput.pcsController.text.trim()),
        masterDataId: masterData.id!,
        designNo: masterData.designNo,
        fileName: masterData.fileName,
        jaluNo: masterData.jaluNo,
        qualityName: _masterDataController.getQualityName(
          masterData.qualityId,
          masterData.qualityName,
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }).toList();

    final order = OrderModel(
      userId: _authController.user!.uid,
      partyName: _partyNameController.text.trim(),
      items: items,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await _orderController.createOrder(order);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order created successfully!'),
          backgroundColor: AppTheme.successColor,
          duration: Duration(seconds: 2),
        ),
      );
      if (Get.previousRoute.isEmpty) {
        Get.offAllNamed('/analytics');
      } else {
        Get.back();
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_orderController.errorMessage.value),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 3),
        ),
      );
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
                      constraints: const BoxConstraints(maxWidth: 900),
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
                Get.offAllNamed('/analytics');
              } else {
                Get.back();
              }
            },
          ),
          const SizedBox(width: 8),
          Text(
            'Create New Order',
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
              controller: _partyNameController,
              label: 'Party Name',
              hint: 'Enter party name',
              icon: Icons.business_rounded,
              themeProvider: themeProvider,
              validator: (value) {
                if (!_validationActivated) return null;
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter party name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: _addOrderItem,
                  icon: const Icon(Icons.add_circle_rounded, color: AppTheme.primaryColor, size: 28),
                  tooltip: 'Add Item',
                ),
              ],
            ),
            const SizedBox(height: 16),

            ..._orderItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildOrderItemCard(
                  index,
                  item,
                  themeProvider,
                  isMobile,
                ),
              );
            }).toList(),

            const SizedBox(height: 20),
            _buildTextArea(
              controller: _notesController,
              label: 'Notes (Optional)',
              hint: 'Add any additional notes or comments',
              icon: Icons.note_rounded,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 32),
            Obx(() => _buildSubmitButton(themeProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemCard(
      int index,
      OrderItemInput item,
      ThemeProvider themeProvider,
      bool isMobile,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Item ${index + 1}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              if (_orderItems.length > 1)
                IconButton(
                  onPressed: () => _removeOrderItem(index),
                  icon: const Icon(Icons.delete_rounded, color: AppTheme.errorColor),
                  tooltip: 'Remove Item',
                ),
            ],
          ),
          const SizedBox(height: 12),

          _buildMasterDataDropdown(item, themeProvider),

          const SizedBox(height: 12),

          TextFormField(
            controller: item.pcsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: 'Pieces',
              hintText: 'Enter number of pieces',
              prefixIcon: Icon(
                Icons.numbers_rounded,
                color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
              ),
              filled: true,
              fillColor: themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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
          ),

          if (item.selectedMasterData != null) ...[
            const SizedBox(height: 12),
            _buildMasterDataDetails(item.selectedMasterData!, themeProvider),
          ],
        ],
      ),
    );
  }

  Widget _buildMasterDataDropdown(
      OrderItemInput item,
      ThemeProvider themeProvider,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Master Data',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final masterDataList = _masterDataController.masterDataList;

          if (masterDataList.isEmpty) {
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
                  const Icon(Icons.info_outline_rounded, color: AppTheme.warningColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No master data available. Please create master data first.',
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return GestureDetector(
            onTap: () async {
              final selectedData = await showMasterDataSearchDialog(context);
              if (selectedData != null) {
                setState(() {
                  item.selectedMasterData = selectedData;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    Icons.search_rounded,
                    color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.selectedMasterData != null
                          ? '${item.selectedMasterData!.designNo} - ${item.selectedMasterData!.fileName}'
                          : 'Search and select master data',
                      style: TextStyle(
                        color: item.selectedMasterData != null
                            ? (themeProvider.isDarkMode ? Colors.white : Colors.black87)
                            : (themeProvider.isDarkMode ? Colors.white38 : Colors.black38),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMasterDataDetails(
      MasterDataModel masterData,
      ThemeProvider themeProvider,
      ) {
    final qualityName = _masterDataController.getQualityName(
      masterData.qualityId,
      masterData.qualityName,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.layers_rounded, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Selected Master Data',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Design: ${masterData.designNo}',
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          Text(
            'File: ${masterData.fileName}',
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          Text(
            'Jalu: ${masterData.jaluNo} • Quality: $qualityName',
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
            ),
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

  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeProvider themeProvider,
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
          maxLines: 4,
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white38 : Colors.black38,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Icon(
                icon,
                color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
              ),
            ),
            filled: true,
            fillColor: themeProvider.isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ThemeProvider themeProvider) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _orderController.isLoading.value ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.6),
        ),
        child: _orderController.isLoading.value
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          'Create Order',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// Helper class for order item input
class OrderItemInput {
  final TextEditingController pcsController;
  MasterDataModel? selectedMasterData;

  OrderItemInput() : pcsController = TextEditingController();

  void dispose() {
    pcsController.dispose();
  }
}