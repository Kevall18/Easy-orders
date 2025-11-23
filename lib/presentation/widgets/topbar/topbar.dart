import 'dart:ui';
import 'package:easy_orders/core/controllers/auth_controller.dart';
import 'package:easy_orders/core/providers/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../../core/providers/sidebar_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';

class Topbar extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const Topbar({
    super.key,
    this.onMenuPressed,
  });

  @override
  State<Topbar> createState() => _TopbarState();
}

class _TopbarState extends State<Topbar> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer3<SidebarProvider, ThemeProvider, SearchProvider>(
      builder: (context, sidebarProvider, themeProvider, searchProvider, child) {
        final isMobile = sidebarProvider.isMobile;
        final activeRoute = sidebarProvider.activeRoute;

        // Determine if search should be shown based on active route
        final showSearch = activeRoute == '/analytics' ||
            activeRoute == '/qualities' ||
            activeRoute == '/master-data';

        return Container(
          height: 80,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: themeProvider.isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                ),
                child: Row(
                  children: [
                    // Menu Toggle Button
                    _buildMenuButton(sidebarProvider, themeProvider, isMobile),

                    SizedBox(width: isMobile ? 12 : 24),

                    // Search Bar (only show on list pages)
                    if (showSearch)
                      Expanded(
                        child: _buildSearchBar(themeProvider, searchProvider, isMobile, activeRoute),
                      )
                    else
                      const Spacer(),

                    SizedBox(width: isMobile ? 12 : 24),

                    // Mobile: Logout Button, Desktop: Notifications
                    if (isMobile)
                      _buildMobileLogoutButton(themeProvider)
                    else
                      _buildNotificationButton(themeProvider),

                    if (!isMobile) ...[
                      const SizedBox(width: 16),
                      // User Profile (hide on mobile)
                      _buildUserProfile(themeProvider),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuButton(
      SidebarProvider sidebarProvider,
      ThemeProvider themeProvider,
      bool isMobile,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () {
          if (isMobile && widget.onMenuPressed != null) {
            widget.onMenuPressed!();
          } else {
            sidebarProvider.toggleSidebar();
          }
        },
        icon: Icon(
          Icons.menu_rounded,
          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
        ),
        tooltip: 'Toggle Menu',
      ),
    );
  }

  Widget _buildSearchBar(ThemeProvider themeProvider, SearchProvider searchProvider, bool isMobile, String activeRoute) {
    String placeholder = 'Search...';

    // Customize placeholder based on active route
    switch (activeRoute) {
      case '/analytics':
        placeholder = 'Search orders...';
        break;
      case '/qualities':
        placeholder = 'Search qualities...';
        break;
      case '/master-data':
        placeholder = 'Search master data...';
        break;
    }

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            Icons.search_rounded,
            size: isMobile ? 20 : 24,
            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: searchProvider.searchController,
              onChanged: (value) => searchProvider.updateSearchQuery(value),
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: themeProvider.isDarkMode
                    ? Colors.white
                    : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  color: themeProvider.isDarkMode
                      ? Colors.white54
                      : Colors.black38,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (searchProvider.searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear_rounded,
                size: 20,
                color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
              ),
              onPressed: () => searchProvider.clearSearch(),
              tooltip: 'Clear search',
            )
          else
            const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(ThemeProvider themeProvider) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              // Notification functionality remains for desktop
              // You can add your notification logic here
            },
            icon: Icon(
              Icons.notifications_rounded,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
            tooltip: 'Notifications',
          ),
        ),
        // You can keep notification count if needed
        // Positioned(
        //   top: 8,
        //   right: 8,
        //   child: Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        //     decoration: BoxDecoration(
        //       color: AppTheme.errorColor,
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //     child: Text(
        //       '5', // Replace with actual count
        //       style: const TextStyle(
        //         color: Colors.white,
        //         fontSize: 10,
        //         fontWeight: FontWeight.w600,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildMobileLogoutButton(ThemeProvider themeProvider) {
    final authController = Get.find<AuthController>();

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () async {
          final shouldLogout = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
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
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (shouldLogout == true) {
            await authController.signOut();
          }
        },
        icon: Icon(
          Icons.logout_rounded,
          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
        ),
        tooltip: 'Logout',
      ),
    );
  }

  Widget _buildUserProfile(ThemeProvider themeProvider) {
    final authController = Get.find<AuthController>();

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Obx(() {
          final user = authController.firestoreUser.value;
          final userName = user?.name ?? 'Guest';
          final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'G';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    userInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  userName,
                  style: TextStyle(
                    color:
                    themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color:
                  themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ],
            ),
          );
        }),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'profile',
            child: Row(
              children: [
                Icon(Icons.person_rounded),
                SizedBox(width: 8),
                Text('Profile'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.settings_rounded),
                SizedBox(width: 8),
                Text('Settings'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout_rounded, color: Colors.red),
                SizedBox(width: 8),
                Text('Logout', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
        onSelected: (value) async {
          if (value == 'logout') {
            final shouldLogout = await Get.dialog<bool>(
              AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
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
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );

            if (shouldLogout == true) {
              await authController.signOut();
            }
          }
        },
      ),
    );
  }
}