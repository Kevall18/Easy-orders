// lib/presentation/pages/master_data/master_data_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/controllers/master_data_controller.dart';
import '../../../../core/models/master_data_model.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/search_provider.dart';
import '../../../../core/theme/app_theme.dart';

class MasterDataListPage extends StatefulWidget {
  const MasterDataListPage({super.key});

  @override
  State<MasterDataListPage> createState() => _MasterDataListPageState();
}

class _MasterDataListPageState extends State<MasterDataListPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final MasterDataController _masterDataController = Get.find<MasterDataController>();

  @override
  void initState() {
    super.initState();
    _masterDataController.fetchMasterData();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _confirmDelete(MasterDataModel masterData) async {
    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Master Data'),
        content: Text(
            'Are you sure you want to delete "${masterData.designNo}"? This action cannot be undone.'),
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

    if (shouldDelete == true && masterData.id != null) {
      final success = await _masterDataController.deleteMasterData(masterData.id!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Master data deleted successfully!'),
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

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, SearchProvider>(
      builder: (context, themeProvider, searchProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: themeProvider.isDarkMode
                ? AppTheme.darkBackgroundGradient
                : AppTheme.backgroundGradient,
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(themeProvider),
                    const SizedBox(height: 24),
                    _buildMasterDataCard(themeProvider, searchProvider),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Column(
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
                    'Master Data',
                    style: AppTheme.customTextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      fontSize: isMobile ? 24 : 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your design templates',
                    style: AppTheme.customTextStyle(
                      color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (!isMobile)
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/add-master-data'),
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: Text(
                    'New Template',
                    style: AppTheme.customTextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
          ],
        ),
        if (isMobile) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed('/add-master-data'),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  'New Template',
                  style: AppTheme.customTextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMasterDataCard(ThemeProvider themeProvider, SearchProvider searchProvider) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                  'All Templates (${_masterDataController.totalMasterData})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                )),
                IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                  onPressed: () => _masterDataController.fetchMasterData(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(() {
            if (_masterDataController.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // Use search query from SearchProvider instead of local state
            final filteredMasterData = searchProvider.searchQuery.isEmpty
                ? _masterDataController.masterDataList
                : _masterDataController.searchMasterData(searchProvider.searchQuery);

            if (filteredMasterData.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        searchProvider.searchQuery.isEmpty ? Icons.storage_rounded : Icons.search_off_rounded,
                        size: 64,
                        color: themeProvider.isDarkMode
                            ? Colors.white38
                            : Colors.black38,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchProvider.searchQuery.isEmpty ? 'No master data yet' : 'No results found',
                        style: TextStyle(
                          fontSize: 16,
                          color: themeProvider.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        searchProvider.searchQuery.isEmpty
                            ? 'Create your first template to get started'
                            : 'Try a different search term',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.isDarkMode
                              ? Colors.white54
                              : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final size = MediaQuery.of(context).size;
            final isMobile = size.width < 768;

            if (isMobile) {
              return ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredMasterData.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final masterData = filteredMasterData[index];
                  return _buildMobileMasterDataItem(masterData, themeProvider);
                },
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        themeProvider.isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.03),
                      ),
                      columns: [
                        DataColumn(
                          label: Text(
                            'Design No',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'File Name',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Jalu',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Quality',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Created',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Actions',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                      rows: filteredMasterData.map((masterData) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      masterData.designNo,
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      masterData.fileName,
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      masterData.jaluDisplayName,
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _masterDataController.getQualityName(
                                        masterData.qualityId,
                                        masterData.qualityName,
                                      ),
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      DateFormat('MMM dd, yyyy')
                                          .format(masterData.createdAt),
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility_rounded,
                                        color: AppTheme.primaryColor),
                                    onPressed: () =>
                                        Get.toNamed('/master-data-detail/${masterData.id!}'),
                                    tooltip: 'View Details',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_rounded,
                                        color: AppTheme.errorColor),
                                    onPressed: () => _confirmDelete(masterData),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMobileMasterDataItem(MasterDataModel masterData, ThemeProvider themeProvider) {
    return InkWell(
      onTap: () => Get.toNamed('/master-data-detail/${masterData.id!}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.layers_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    masterData.designNo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${masterData.jaluDisplayName} • ${_masterDataController.getQualityName(masterData.qualityId, masterData.qualityName)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_rounded, color: AppTheme.errorColor),
              onPressed: () => _confirmDelete(masterData),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}