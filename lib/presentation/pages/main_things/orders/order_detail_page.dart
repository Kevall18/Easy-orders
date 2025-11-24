// lib/presentation/pages/orders/order_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/controllers/auth_controller.dart';
import '../../../../core/controllers/master_data_controller.dart';
import '../../../../core/controllers/order_controller.dart';
import '../../../../core/models/master_data_model.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/order_item_pdf_service.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/dialogue_box/master_data_dialogue_box.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage>
    with SingleTickerProviderStateMixin {
  final OrderController _orderController = Get.find<OrderController>();
  final MasterDataController _masterDataController =
      Get.find<MasterDataController>();
  final AuthController _authController = Get.find<AuthController>();
  final PdfService _pdfService = PdfService();
  final OrderItemPdfService _itemPdfService = OrderItemPdfService();

  OrderModel? _order;
  bool _isEditingParty = false;
  final _partyNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  DateTime? _selectedOrderDate;

  // FAB Animation
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
    _masterDataController.fetchMasterData();
    if (_order == null) {
      _fetchOrderFromFirebase();
    }
    // Initialize order date
    if (_order != null) {
      _selectedOrderDate = _order!.orderDate;
    }

    // Initialize FAB animation
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );
  }

  void _loadOrder() {
    _order = _orderController.getOrderById(widget.orderId);
    if (_order != null) {
      _partyNameController.text = _order!.partyName;
      _notesController.text = _order!.notes ?? '';
      _selectedOrderDate = _order!.orderDate; // NEW
    }
  }

  Future<void> _fetchOrderFromFirebase() async {
    try {
      await _orderController.fetchOrders();
      setState(() {
        _order = _orderController.getOrderById(widget.orderId);
        if (_order != null) {
          _partyNameController.text = _order!.partyName;
          _notesController.text = _order!.notes ?? '';
          _selectedOrderDate = _order!.orderDate; // NEW
        }
      });
    } catch (e) {
      print('Error fetching order: $e');
    }
  }

  @override
  void dispose() {
    _partyNameController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  // Toggle FAB Menu
  void _toggleFabMenu() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  // Close FAB Menu
  void _closeFabMenu() {
    if (_isFabOpen) {
      setState(() {
        _isFabOpen = false;
        _fabController.reverse();
      });
    }
  }

  // PDF Generation Bottom Sheet
  void _showPdfOptionsBottomSheet() {
    _closeFabMenu();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'PDF Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color:
                      themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Preview Button
              _buildPdfOptionButton(
                icon: Icons.visibility_rounded,
                label: 'Preview PDF',
                color: AppTheme.primaryColor,
                onTap: () async {
                  Navigator.pop(context);
                  await _previewPdf();
                },
              ),
              const SizedBox(height: 10),

              // Share Button
              _buildPdfOptionButton(
                icon: Icons.share_rounded,
                label: 'Share PDF',
                color: AppTheme.accentColor,
                onTap: () async {
                  Navigator.pop(context);
                  await _sharePdf();
                },
              ),
              const SizedBox(height: 10),

              // Download Button
              _buildPdfOptionButton(
                icon: Icons.download_rounded,
                label: 'Download PDF',
                color: AppTheme.successColor,
                onTap: () async {
                  Navigator.pop(context);
                  await _downloadPdf();
                },
              ),
              const SizedBox(height: 10),

              // Print Button
              _buildPdfOptionButton(
                icon: Icons.print_rounded,
                label: 'Print PDF',
                color: AppTheme.warningColor,
                onTap: () async {
                  Navigator.pop(context);
                  await _printPdf();
                },
              ),
              const SizedBox(height: 10),

              // Cancel Button
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: themeProvider.isDarkMode
                        ? Colors.white30
                        : Colors.black26,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPdfOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // PDF Functions
  Future<void> _previewPdf() async {
    if (_order == null) return;

    try {
      final userName =
          _authController.firestoreUser.value?.name ?? 'BHARAT ART';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await _pdfService.previewPdf(_order!, userName);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to preview PDF: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _sharePdf() async {
    if (_order == null) return;

    try {
      final userName =
          _authController.firestoreUser.value?.name ?? 'BHARAT ART';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await _pdfService.sharePdf(_order!, userName);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF shared successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share PDF: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _downloadPdf() async {
    if (_order == null) return;

    try {
      final userName =
          _authController.firestoreUser.value?.name ?? 'BHARAT ART';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final path = await _pdfService.savePdfToLocal(_order!, userName);

      if (mounted) {
        Navigator.pop(context);

        if (path != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF saved: $path'),
              backgroundColor: AppTheme.successColor,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save PDF'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download PDF: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _printPdf() async {
    if (_order == null) return;

    try {
      final userName =
          _authController.firestoreUser.value?.name ?? 'BHARAT ART';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await _pdfService.printPdf(_order!, userName);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print PDF: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  // Delete Whole Order
  Future<void> _deleteWholeOrder() async {
    _closeFabMenu();

    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Order'),
        content: const Text(
          'Are you sure you want to delete this entire order? This action cannot be undone.',
        ),
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
            child: const Text('Delete Order'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final success = await _orderController.deleteOrder(widget.orderId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order deleted successfully!'),
            backgroundColor: AppTheme.successColor,
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
          ),
        );
      }
    }
  }

  Future<void> _updatePartyInfo() async {
    if (_order == null || _selectedOrderDate == null) return;

    final updatedOrder = _order!.copyWith(
      partyName: _partyNameController.text.trim(),
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      orderDate: _selectedOrderDate, // NEW: Include order date in update
    );

    final success = await _orderController.updateOrder(updatedOrder);

    if (success && mounted) {
      setState(() {
        _order = updatedOrder;
        _isEditingParty = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Party information updated!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_orderController.errorMessage.value),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }


  Future<void> _updateItemStatus(int index, String newStatus) async {
    if (_order == null) return;

    final success = await _orderController.updateItemStatus(
      widget.orderId,
      index,
      newStatus,
    );

    if (success && mounted) {
      setState(() {
        _order = _orderController.getOrderById(widget.orderId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item status updated!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_orderController.errorMessage.value),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _showDispatchDialog(int index) async {
    final item = _order!.items[index];
    final dispatchController = TextEditingController();

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return AlertDialog(
          backgroundColor:
              themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
          title: Text(
            'Dispatch Items',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Design: ${item.designNo}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color:
                      themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total Pieces: ${item.pcs}',
                style: TextStyle(
                  color: themeProvider.isDarkMode
                      ? Colors.white70
                      : Colors.black54,
                ),
              ),
              Text(
                'Already Dispatched: ${item.dispatchedPcs}',
                style: TextStyle(
                  color: themeProvider.isDarkMode
                      ? Colors.white70
                      : Colors.black54,
                ),
              ),
              Text(
                'Remaining: ${item.remainingPcs}',
                style: TextStyle(
                  color: themeProvider.isDarkMode
                      ? Colors.white70
                      : Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dispatchController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
                style: TextStyle(
                  color:
                      themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  labelText: 'Pieces to Dispatch',
                  hintText: 'Enter number of pieces',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final pcs = int.tryParse(dispatchController.text.trim());
                if (pcs != null && pcs > 0 && pcs <= item.remainingPcs) {
                  Navigator.pop(context, pcs);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        pcs == null || pcs <= 0
                            ? 'Please enter a valid number'
                            : 'Cannot dispatch more than ${item.remainingPcs} pieces',
                      ),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
              ),
              child: const Text('Dispatch'),
            ),
          ],
        );
      },
    );

    if (result != null && mounted) {
      final success = await _orderController.dispatchItem(
        widget.orderId,
        index,
        result,
      );

      if (success && mounted) {
        setState(() {
          _order = _orderController.getOrderById(widget.orderId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$result pieces dispatched successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_orderController.errorMessage.value),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _deleteItem(int index) async {
    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Item'),
        content: Text(
          _order!.items.length == 1
              ? 'This is the last item. Deleting it will delete the entire order. Continue?'
              : 'Are you sure you want to delete this item?',
        ),
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

    if (shouldDelete == true) {
      final success =
          await _orderController.deleteOrderItem(widget.orderId, index);

      if (success && mounted) {
        if (_order!.items.length == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order deleted successfully!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          if (Get.previousRoute.isEmpty) {
            Get.offAllNamed('/analytics');
          } else {
            Get.back();
          }
        } else {
          setState(() {
            _order = _orderController.getOrderById(widget.orderId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item deleted successfully!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_orderController.errorMessage.value),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showAddItemDialog() {
    _closeFabMenu();
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        orderId: widget.orderId,
        onItemAdded: () {
          setState(() {
            _order = _orderController.getOrderById(widget.orderId);
          });
        },
      ),
    );
  }

  // NEW: Method to select order date
  Future<void> _selectOrderDate() async {
    if (_selectedOrderDate == null) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedOrderDate!,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white,
              onSurface: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedOrderDate) {
      setState(() {
        _selectedOrderDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    if (_order == null) {
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
                  'Loading order...',
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: GestureDetector(
        onTap: _closeFabMenu,
        child: Container(
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
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          children: [
                            _buildPartyInfoCard(themeProvider, isMobile),
                            const SizedBox(height: 24),
                            _buildSummaryCard(themeProvider, isMobile),
                            const SizedBox(height: 24),
                            _buildItemsCard(themeProvider, isMobile),
                            const SizedBox(height: 100), // Space for FAB
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFabMenu(),
    );
  }

  // Build FAB Menu (Google Calendar style)
  Widget _buildFabMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Add Item FAB
        ScaleTransition(
          scale: _fabAnimation,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Add Item',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  heroTag: 'add_item_fab',
                  onPressed: _showAddItemDialog,
                  backgroundColor: AppTheme.primaryColor,
                  child: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
        ),

        // Generate PDF FAB
        ScaleTransition(
          scale: _fabAnimation,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Generate PDF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  heroTag: 'pdf_fab',
                  onPressed: _showPdfOptionsBottomSheet,
                  backgroundColor: AppTheme.accentColor,
                  child: const Icon(Icons.picture_as_pdf_rounded),
                ),
              ],
            ),
          ),
        ),

        // Delete Order FAB
        ScaleTransition(
          scale: _fabAnimation,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Delete Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  heroTag: 'delete_order_fab',
                  onPressed: _deleteWholeOrder,
                  backgroundColor: AppTheme.errorColor,
                  child: const Icon(Icons.delete_rounded),
                ),
              ],
            ),
          ),
        ),

        // Main FAB (Menu Toggle)
        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: _toggleFabMenu,
          backgroundColor: AppTheme.primaryColor,
          child: AnimatedRotation(
            turns: _isFabOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(_isFabOpen ? Icons.close : Icons.more_vert_rounded),
          ),
        ),
      ],
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
          Expanded(
            child: Text(
              'Order Details',
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.w700,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyInfoCard(ThemeProvider themeProvider, bool isMobile) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Party Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              if (!_isEditingParty)
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: AppTheme.primaryColor),
                  onPressed: () {
                    setState(() {
                      _isEditingParty = true;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isEditingParty) ...[
            TextField(
              controller: _partyNameController,
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: 'Party Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // NEW: Order Date Picker in Edit Mode
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectOrderDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: themeProvider.isDarkMode
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedOrderDate != null
                                ? DateFormat('MMM dd, yyyy').format(_selectedOrderDate!)
                                : 'Select date',
                            style: TextStyle(
                              fontSize: 16,
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
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
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _notesController,
              maxLines: 3,
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isEditingParty = false;
                        _partyNameController.text = _order!.partyName;
                        _notesController.text = _order!.notes ?? '';
                        _selectedOrderDate = _order!.orderDate; // Reset order date
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.errorColor),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: AppTheme.errorColor)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updatePartyInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildInfoRow('Party Name', _order!.partyName, themeProvider),
            const SizedBox(height: 12),
            // NEW: Show Order Date instead of Created At
            _buildInfoRow(
              'Order Date',
              DateFormat('MMM dd, yyyy').format(_order!.orderDate),
              themeProvider,
            ),
            if (_order!.notes != null && _order!.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Notes', _order!.notes!, themeProvider),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              'Created',
              DateFormat('MMM dd, yyyy hh:mm a').format(_order!.createdAt),
              themeProvider,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeProvider themeProvider, bool isMobile) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Items',
                  _order!.items.length.toString(),
                  Icons.inventory_2_rounded,
                  AppTheme.primaryColor,
                  themeProvider,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  'Total Pieces',
                  _order!.totalPcs.toString(),
                  Icons.shopping_bag_rounded,
                  AppTheme.accentColor,
                  themeProvider,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Dispatched',
                  _order!.totalDispatchedPcs.toString(),
                  Icons.check_circle_rounded,
                  AppTheme.successColor,
                  themeProvider,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  'Remaining',
                  _order!.totalRemainingPcs.toString(),
                  Icons.pending_rounded,
                  AppTheme.warningColor,
                  themeProvider,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeProvider themeProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: themeProvider.isDarkMode
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(ThemeProvider themeProvider, bool isMobile) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Order Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: _order!.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildOrderItemCard(
                  index, _order!.items[index], themeProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(
      int index, OrderItem item, ThemeProvider themeProvider) {
    final qualityName = _masterDataController.getQualityName(
      item.masterDataId,
      item.qualityName,
    );

    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item ${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.isDarkMode
                            ? Colors.white54
                            : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.designNo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    Text(
                      'File: ${item.fileName}',
                      style: TextStyle(
                        fontSize: 13,
                        color: themeProvider.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded,
                        color: AppTheme.accentColor),
                    onPressed: () => _showEditItemDialog(index, item),
                    tooltip: 'Edit Item',
                  ),
                  IconButton(
                    icon: const Icon(Icons.print,
                        color: AppTheme.primaryColor),
                    onPressed: () => _showItemPdfOptionsBottomSheet(item),
                    tooltip: 'Print Item',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_rounded,
                        color: AppTheme.errorColor),
                    onPressed: () => _deleteItem(index),
                    tooltip: 'Delete Item',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jalu: ${item.jaluNo}',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                      Text(
                        'Quality: $qualityName',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPiecesInfo('Total', item.pcs.toString(),
                    AppTheme.primaryColor, themeProvider),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPiecesInfo(
                    'Dispatched',
                    item.dispatchedPcs.toString(),
                    AppTheme.successColor,
                    themeProvider),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPiecesInfo(
                    'Remaining',
                    item.remainingPcs.toString(),
                    AppTheme.warningColor,
                    themeProvider),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item Status',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: item.itemStatus,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      dropdownColor: themeProvider.isDarkMode
                          ? Colors.grey[900]
                          : Colors.white,
                      style: TextStyle(
                        fontSize: 13,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(
                            value: 'finishing', child: Text('Finishing')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _updateItemStatus(index, value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ElevatedButton.icon(
                      onPressed: item.remainingPcs > 0
                          ? () => _showDispatchDialog(index)
                          : null,
                      icon: const Icon(Icons.local_shipping_rounded, size: 16),
                      label: Text(
                        item.deliveryStatus == 'dispatched'
                            ? 'Dispatched'
                            : 'Dispatch',
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.deliveryStatus == 'dispatched'
                            ? AppTheme.successColor
                            : AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.dispatchDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 14, color: AppTheme.successColor),
                  const SizedBox(width: 8),
                  Text(
                    'Dispatched: ${DateFormat('MMM dd, yyyy').format(item.dispatchDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildPiecesInfo(
      String label, String value, Color color, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, ThemeProvider themeProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
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
  void _showItemPdfOptionsBottomSheet(OrderItem item) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Program PDF Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle with item info
              Text(
                '${item.designNo} - ${item.fileName}',
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Preview Button
              _buildPdfOptionButton(
                icon: Icons.visibility_rounded,
                label: 'Preview PDF',
                color: AppTheme.primaryColor,
                onTap: () async {
                  Navigator.pop(context);
                  await _previewItemPdf(item);
                },
              ),
              const SizedBox(height: 10),

              // Share Button
              _buildPdfOptionButton(
                icon: Icons.share_rounded,
                label: 'Share PDF',
                color: AppTheme.accentColor,
                onTap: () async {
                  Navigator.pop(context);
                  await _shareItemPdf(item);
                },
              ),
              const SizedBox(height: 10),

              // Download Button
              _buildPdfOptionButton(
                icon: Icons.download_rounded,
                label: 'Download PDF',
                color: AppTheme.successColor,
                onTap: () async {
                  Navigator.pop(context);
                  await _downloadItemPdf(item);
                },
              ),
              const SizedBox(height: 10),

              // Print Button
              _buildPdfOptionButton(
                icon: Icons.print_rounded,
                label: 'Print PDF',
                color: AppTheme.warningColor,
                onTap: () async {
                  Navigator.pop(context);
                  await _printItemPdf(item);
                },
              ),
              const SizedBox(height: 10),

              // Cancel Button
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: themeProvider.isDarkMode
                        ? Colors.white30
                        : Colors.black26,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Preview Item PDF
  Future<void> _previewItemPdf(OrderItem item) async {
    try {
      final userName = _authController.firestoreUser.value?.name ?? 'BHARAT ART';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await _itemPdfService.previewPdf(item, userName);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to preview PDF: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

// Share Item PDF
  Future<void> _shareItemPdf(OrderItem item) async {
    try {
      final userName = _authController.firestoreUser.value?.name ?? 'BHARAT ART';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await _itemPdfService.sharePdf(item, userName);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF shared successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share PDF: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

// Download Item PDF
  Future<void> _downloadItemPdf(OrderItem item) async {
    try {
      final userName = _authController.firestoreUser.value?.name ?? 'BHARAT ART';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final path = await _itemPdfService.savePdfToLocal(item, userName);

      if (mounted) {
        Navigator.pop(context);

        if (path != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF saved: $path'),
              backgroundColor: AppTheme.successColor,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save PDF'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download PDF: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

// Print Item PDF
  Future<void> _printItemPdf(OrderItem item) async {
    try {
      final userName = _authController.firestoreUser.value?.name ?? 'BHARAT ART';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await _itemPdfService.printPdf(item, userName);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print PDF: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
  void _showEditItemDialog(int index, OrderItem item) {
    _closeFabMenu();
    showDialog(
      context: context,
      builder: (context) => _EditItemDialog(
        orderId: widget.orderId,
        itemIndex: index,
        currentItem: item,
        onItemUpdated: () {
          setState(() {
            _order = _orderController.getOrderById(widget.orderId);
          });
        },
      ),
    );
  }
}

// Add Item Dialog Widget
class _AddItemDialog extends StatefulWidget {
  final String orderId;
  final VoidCallback onItemAdded;

  const _AddItemDialog({
    required this.orderId,
    required this.onItemAdded,
  });

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final OrderController _orderController = Get.find<OrderController>();
  final MasterDataController _masterDataController = Get.find<MasterDataController>();
  final TextEditingController _pcsController = TextEditingController();

  MasterDataModel? _selectedMasterData;
  bool _isLoading = false;

  @override
  void dispose() {
    _pcsController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    if (_selectedMasterData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select master data'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final pcs = int.tryParse(_pcsController.text.trim());
    if (pcs == null || pcs <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid number of pieces'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final newItem = OrderItem(
      pcs: pcs,
      masterDataId: _selectedMasterData!.id!,
      designNo: _selectedMasterData!.designNo,
      fileName: _selectedMasterData!.fileName,
      jaluNo: _selectedMasterData!.jaluNo,
      qualityName: _masterDataController.getQualityName(
        _selectedMasterData!.qualityId,
        _selectedMasterData!.qualityName,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await _orderController.addItemToOrder(widget.orderId, newItem);

    setState(() => _isLoading = false);

    if (success && mounted) {
      widget.onItemAdded();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item added successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_orderController.errorMessage.value),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AlertDialog(
      backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
      title: Text(
        'Add New Item',
        style: TextStyle(
          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          'No master data available',
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
                  final selectedData = await showMasterDataSearchDialog(
                    context,
                    title: 'Select Master Data for New Item',
                  );
                  if (selectedData != null) {
                    setState(() {
                      _selectedMasterData = selectedData;
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
                          _selectedMasterData != null
                              ? '${_selectedMasterData!.designNo} - ${_selectedMasterData!.fileName}'
                              : 'Search and select master data',
                          style: TextStyle(
                            color: _selectedMasterData != null
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
            if (_selectedMasterData != null) ...[
              const SizedBox(height: 12),
              Container(
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
                      'Design: ${_selectedMasterData!.designNo}',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    Text(
                      'File: ${_selectedMasterData!.fileName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    Text(
                      'Jalu: ${_selectedMasterData!.jaluNo} • Quality: ${_masterDataController.getQualityName(_selectedMasterData!.qualityId, _selectedMasterData!.qualityName)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _pcsController,
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : const Text('Add Item'),
        ),
      ],
    );
  }
}

class _EditItemDialog extends StatefulWidget {
  final String orderId;
  final int itemIndex;
  final OrderItem currentItem;
  final VoidCallback onItemUpdated;

  const _EditItemDialog({
    required this.orderId,
    required this.itemIndex,
    required this.currentItem,
    required this.onItemUpdated,
  });

  @override
  State<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  final OrderController _orderController = Get.find<OrderController>();
  final MasterDataController _masterDataController = Get.find<MasterDataController>();
  final TextEditingController _pcsController = TextEditingController();

  MasterDataModel? _selectedMasterData;
  bool _isLoading = false;
  bool _resetDispatchStatus = false;

  @override
  void initState() {
    super.initState();
    _pcsController.text = widget.currentItem.pcs.toString();

    // Find the current master data
    try {
      _selectedMasterData = _masterDataController.masterDataList.firstWhere(
            (data) => data.id == widget.currentItem.masterDataId,
      );
    } catch (e) {
      print('Could not find master data: $e');
    }
  }

  @override
  void dispose() {
    _pcsController.dispose();
    super.dispose();
  }

  Future<void> _updateItem() async {
    if (_selectedMasterData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select master data'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final pcs = int.tryParse(_pcsController.text.trim());
    if (pcs == null || pcs <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid number of pieces'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Validation: Cannot make total pcs lower than dispatched pieces (unless resetting)
    if (!_resetDispatchStatus && pcs < widget.currentItem.dispatchedPcs) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Total pieces ($pcs) cannot be lower than dispatched pieces (${widget.currentItem.dispatchedPcs}). '
                'Please check "Reset Dispatch Status" to reset dispatched pieces.',
          ),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Create updated item
    final updatedItem = widget.currentItem.copyWith(
      pcs: pcs,
      masterDataId: _selectedMasterData!.id!,
      designNo: _selectedMasterData!.designNo,
      fileName: _selectedMasterData!.fileName,
      jaluNo: _selectedMasterData!.jaluNo,
      qualityName: _masterDataController.getQualityName(
        _selectedMasterData!.qualityId,
        _selectedMasterData!.qualityName,
      ),
      dispatchedPcs: _resetDispatchStatus ? 0 : null,
      dispatchDate: _resetDispatchStatus ? () => null : null, // Use function wrapper to set null
      deliveryStatus: _resetDispatchStatus ? 'awaiting_dispatch' : null,
      updatedAt: DateTime.now(),
    );

    final success = await _orderController.updateOrderItem(
      widget.orderId,
      widget.itemIndex,
      updatedItem,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      widget.onItemUpdated();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item updated successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_orderController.errorMessage.value),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AlertDialog(
      backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
      title: Text(
        'Edit Item',
        style: TextStyle(
          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current item info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Current Item Info',
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
                      'Total Pieces: ${widget.currentItem.pcs}',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    Text(
                      'Dispatched: ${widget.currentItem.dispatchedPcs}',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    Text(
                      'Remaining: ${widget.currentItem.remainingPcs}',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Master Data Selection
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
                            'No master data available',
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
                    final selectedData = await showMasterDataSearchDialog(
                      context,
                      title: 'Select Master Data for Item',
                    );
                    if (selectedData != null) {
                      setState(() {
                        _selectedMasterData = selectedData;
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
                            _selectedMasterData != null
                                ? '${_selectedMasterData!.designNo} - ${_selectedMasterData!.fileName}'
                                : 'Search and select master data',
                            style: TextStyle(
                              color: _selectedMasterData != null
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

              if (_selectedMasterData != null) ...[
                const SizedBox(height: 12),
                Container(
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
                        'Design: ${_selectedMasterData!.designNo}',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      Text(
                        'File: ${_selectedMasterData!.fileName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      Text(
                        'Jalu: ${_selectedMasterData!.jaluNo} • Quality: ${_masterDataController.getQualityName(_selectedMasterData!.qualityId, _selectedMasterData!.qualityName)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Total Pieces Input
              TextField(
                controller: _pcsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  labelText: 'Total Pieces',
                  hintText: 'Enter number of pieces',
                  prefixIcon: Icon(
                    Icons.numbers_rounded,
                    color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Reset Dispatch Status Checkbox
              Container(
                decoration: BoxDecoration(
                  color: _resetDispatchStatus
                      ? AppTheme.warningColor.withOpacity(0.1)
                      : (themeProvider.isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _resetDispatchStatus
                        ? AppTheme.warningColor.withOpacity(0.3)
                        : (themeProvider.isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1)),
                  ),
                ),
                child: CheckboxListTile(
                  value: _resetDispatchStatus,
                  onChanged: (value) {
                    setState(() {
                      _resetDispatchStatus = value ?? false;
                    });
                  },
                  title: Text(
                    'Reset Dispatch Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'This will reset dispatched pieces to 0 and clear dispatch date',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  activeColor: AppTheme.warningColor,
                  checkColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              if (_resetDispatchStatus) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.warningColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: AppTheme.warningColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Warning: This will clear ${widget.currentItem.dispatchedPcs} dispatched pieces',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : const Text('Update Item'),
        ),
      ],
    );
  }
}