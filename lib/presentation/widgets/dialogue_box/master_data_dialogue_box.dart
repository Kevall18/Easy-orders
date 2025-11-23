// lib/presentation/widgets/master_data_search_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../core/controllers/master_data_controller.dart';
import '../../../core/models/master_data_model.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';

class MasterDataSearchDialog extends StatefulWidget {
  final Function(MasterDataModel) onMasterDataSelected;
  final String title;
  final String? subtitle;

  const MasterDataSearchDialog({
    super.key,
    required this.onMasterDataSelected,
    this.title = 'Select Master Data',
    this.subtitle,
  });

  @override
  State<MasterDataSearchDialog> createState() => _MasterDataSearchDialogState();
}

class _MasterDataSearchDialogState extends State<MasterDataSearchDialog> {
  final MasterDataController _masterDataController = Get.find<MasterDataController>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: StatefulBuilder(
        builder: (context, setDialogState) {
          final filteredList = _searchQuery.isEmpty
              ? _masterDataController.masterDataList
              : _masterDataController.searchMasterData(_searchQuery);

          return Container(
            width: 600,
            constraints: const BoxConstraints(maxHeight: 700),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? const Color(0xFF1E293B)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(themeProvider, filteredList.length),

                // Search field
                _buildSearchField(themeProvider, setDialogState),

                // List of master data
                _buildMasterDataList(themeProvider, filteredList),

                // Footer with total count
                if (filteredList.isNotEmpty)
                  _buildFooter(themeProvider, filteredList.length),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider, int itemCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.02),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
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
          Container(
            padding: const EdgeInsets.all(10),
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle ?? '$itemCount items available',
                  style: TextStyle(
                    fontSize: 13,
                    color: themeProvider.isDarkMode
                        ? Colors.white60
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: themeProvider.isDarkMode
                  ? Colors.white70
                  : Colors.black54,
            ),
            onPressed: () {
              _searchController.clear();
              _searchQuery = '';
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeProvider themeProvider, StateSetter setDialogState) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (value) {
          setDialogState(() {
            _searchQuery = value;
          });
        },
        style: TextStyle(
          color: themeProvider.isDarkMode
              ? Colors.white
              : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'Search by design no, file name, jalu, quality...',
          hintStyle: TextStyle(
            color: themeProvider.isDarkMode
                ? Colors.white38
                : Colors.black38,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: themeProvider.isDarkMode
                ? Colors.white54
                : Colors.black54,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear_rounded),
            onPressed: () {
              _searchController.clear();
              setDialogState(() {
                _searchQuery = '';
              });
            },
            color: themeProvider.isDarkMode
                ? Colors.white54
                : Colors.black54,
          )
              : null,
          filled: true,
          fillColor: themeProvider.isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
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
            borderSide: const BorderSide(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMasterDataList(ThemeProvider themeProvider, List<MasterDataModel> filteredList) {
    return Flexible(
      child: filteredList.isEmpty
          ? _buildEmptyState(themeProvider)
          : ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final masterData = filteredList[index];
          final qualityName = _masterDataController.getQualityName(
            masterData.qualityId,
            masterData.qualityName,
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.03)
                  : Colors.black.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            child: InkWell(
              onTap: () {
                widget.onMasterDataSelected(masterData);
                _searchController.clear();
                _searchQuery = '';
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            masterData.designNo,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            masterData.fileName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.grid_on_rounded,
                          size: 16,
                          color: themeProvider.isDarkMode
                              ? Colors.white54
                              : Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Jalu: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: themeProvider.isDarkMode
                                ? Colors.white54
                                : Colors.black54,
                          ),
                        ),
                        Text(
                          masterData.jaluNo.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Icon(
                          Icons.stars_rounded,
                          size: 16,
                          color: themeProvider.isDarkMode
                              ? Colors.white54
                              : Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Quality: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: themeProvider.isDarkMode
                                ? Colors.white54
                                : Colors.black54,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            qualityName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: themeProvider.isDarkMode
                  ? Colors.white24
                  : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              'No master data found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: themeProvider.isDarkMode
                    ? Colors.white70
                    : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search',
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.isDarkMode
                    ? Colors.white38
                    : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeProvider themeProvider, int itemCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.02),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: themeProvider.isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: themeProvider.isDarkMode
                ? Colors.white54
                : Colors.black54,
          ),
          const SizedBox(width: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Showing all $itemCount items'
                : 'Found $itemCount matching items',
            style: TextStyle(
              fontSize: 13,
              color: themeProvider.isDarkMode
                  ? Colors.white60
                  : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show the dialog
Future<MasterDataModel?> showMasterDataSearchDialog(
    BuildContext context, {
      String title = 'Select Master Data',
      String? subtitle,
    }) async {
  MasterDataModel? selectedData;

  await showDialog(
    context: context,
    builder: (context) => MasterDataSearchDialog(
      title: title,
      subtitle: subtitle,
      onMasterDataSelected: (data) {
        selectedData = data;
      },
    ),
  );

  return selectedData;
}