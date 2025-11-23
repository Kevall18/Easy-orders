// lib/presentation/widgets/pagination/pagination_widget.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final int itemsPerPage;
  final Function(int) onItemsPerPageChanged;
  final ThemeProvider themeProvider;
  final int totalItems;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.itemsPerPage,
    required this.onItemsPerPageChanged,
    required this.themeProvider,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        border: Border(
          top: BorderSide(
            color: themeProvider.isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      child: isMobile ? _buildMobilePagination() : _buildDesktopPagination(),
    );
  }

  Widget _buildMobilePagination() {
    return Column(
      children: [
        // Items per page selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Items per page:',
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            DropdownButton<int>(
              value: itemsPerPage,
              dropdownColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
              items: [5, 10, 20, 50].map((value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) onItemsPerPageChanged(value);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Page navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Page $currentPage of $totalPages',
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 20),
                  onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 20),
                  onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopPagination() {
    final startItem = (currentPage - 1) * itemsPerPage + 1;
    final endItem = (startItem + itemsPerPage - 1).clamp(0, totalItems);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Items info
        Text(
          'Showing $startItem-$endItem of $totalItems items',
          style: TextStyle(
            fontSize: 14,
            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        Row(
          children: [
            // Items per page selector
            Text(
              'Items per page:',
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: itemsPerPage,
              dropdownColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
              items: [5, 10, 20, 50].map((value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) onItemsPerPageChanged(value);
              },
            ),
            const SizedBox(width: 24),
            // Page navigation
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 8),
            ..._buildPageNumbers(),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pageNumbers = [];
    int start = (currentPage - 2).clamp(1, totalPages);
    int end = (currentPage + 2).clamp(1, totalPages);

    // Add first page
    if (start > 1) {
      pageNumbers.add(_buildPageButton(1));
      if (start > 2) {
        pageNumbers.add(_buildEllipsis());
      }
    }

    // Add page range
    for (int i = start; i <= end; i++) {
      pageNumbers.add(_buildPageButton(i));
    }

    // Add last page
    if (end < totalPages) {
      if (end < totalPages - 1) {
        pageNumbers.add(_buildEllipsis());
      }
      pageNumbers.add(_buildPageButton(totalPages));
    }

    return pageNumbers;
  }

  Widget _buildPageButton(int page) {
    final isActive = page == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () => onPageChanged(page),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? AppTheme.primaryColor
                  : (themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.1)),
            ),
          ),
          child: Center(
            child: Text(
              page.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? Colors.white
                    : (themeProvider.isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '...',
        style: TextStyle(
          fontSize: 14,
          color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }
}