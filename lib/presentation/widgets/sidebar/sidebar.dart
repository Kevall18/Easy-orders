import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../../core/providers/sidebar_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_router.dart';
import 'sidebar_item.dart';
import 'package:get/get.dart';
import '../../../core/controllers/auth_controller.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SidebarProvider, ThemeProvider>(
      builder: (context, sidebarProvider, themeProvider, child) {
        final isExpanded = sidebarProvider.isMobile ? true : sidebarProvider.isExpanded;
        final sidebarWidth = sidebarProvider.isMobile ? 280.0 : sidebarProvider.sidebarWidth;

        return Container(
          width: sidebarWidth,
          constraints: BoxConstraints(
            maxWidth: sidebarWidth,
            minWidth: sidebarWidth,
          ),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.white.withOpacity(0.8),
            borderRadius: sidebarProvider.isMobile
                ? null
                : const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border.all(
              color: themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              width: 1,
            ),
            boxShadow: sidebarProvider.isMobile ? null : [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(5, 0),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: sidebarProvider.isMobile
                ? BorderRadius.zero
                : const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                children: [
                  _buildLogoSection(isExpanded, themeProvider, sidebarProvider.isMobile),
                  Expanded(
                    child: _buildNavigationItems(
                      sidebarProvider,
                      themeProvider,
                      isExpanded,
                    ),
                  ),
                  _buildBottomSection(themeProvider, isExpanded, sidebarProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoSection(
      bool isExpanded,
      ThemeProvider themeProvider,
      bool isMobile,
      ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'EasyOrders',
                    style: AppTheme.customTextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'Admin Panel',
                    style: AppTheme.customTextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                      fontSize: 11,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildNavigationItems(
      SidebarProvider sidebarProvider,
      ThemeProvider themeProvider,
      bool isExpanded,
      ) {
    final availableRoutes = AppRouter.routes.map((r) => r.name).toSet();
    final String currentActiveRoute = sidebarProvider.activeRoute;

    final navigationItems = <dynamic>[
      SidebarItem(
        icon: Icons.analytics_rounded,
        title: 'Analytics',
        route: '/analytics',
        isActive: currentActiveRoute == '/analytics',
      ),
      SidebarItem(
        icon: Icons.stars_rounded,
        title: 'Qualities',
        route: '/qualities',
        isActive: currentActiveRoute == '/qualities',
      ),
      SidebarItem(
        icon: Icons.layers_rounded,
        title: 'Master Data',
        route: '/master-data',
        isActive: currentActiveRoute == '/master-data',
      ),
      SidebarItem(
        icon: Icons.calendar_month,
        title: 'Program data',
        route: '/calendar',
        isActive: currentActiveRoute == '/calendar',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: navigationItems.length,
      itemBuilder: (context, index) {
        final item = navigationItems[index];
        if (item is SizedBox) return item;

        if (item is SidebarItem) {
          if (item.route.isNotEmpty && !availableRoutes.contains(item.route)) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SidebarItemWidget(
              item: item,
              isExpanded: isExpanded,
              themeProvider: themeProvider,
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomSection(
      ThemeProvider themeProvider,
      bool isExpanded,
      SidebarProvider sidebarProvider,
      ) {
    final authController = Get.find<AuthController>();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Theme Toggle
          Container(
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                themeProvider.isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
              title: isExpanded
                  ? Text(
                themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                style: AppTheme.customTextStyle(
                  color: themeProvider.isDarkMode
                      ? Colors.white
                      : Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  overflow: TextOverflow.ellipsis,
                ),
              )
                  : null,
              onTap: () => themeProvider.toggleTheme(),
            ),
          ),

          const SizedBox(height: 8),

          // User Profile - Clickable to navigate to profile page
          Obx(() {
            final user = authController.firestoreUser.value;
            final userName = user?.name ?? 'Guest';
            final userEmail = user?.email ?? 'guest@example.com';
            final userInitial =
            userName.isNotEmpty ? userName[0].toUpperCase() : 'G';

            return Container(
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    userInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: isExpanded
                    ? Text(
                  userName,
                  style: AppTheme.customTextStyle(
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
                    : null,
                subtitle: isExpanded
                    ? Text(
                  userEmail,
                  style: AppTheme.customTextStyle(
                    color: themeProvider.isDarkMode
                        ? Colors.white70
                        : Colors.black54,
                    fontSize: 11,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
                    : null,
                trailing: isExpanded
                    ? Icon(
                  Icons.chevron_right_rounded,
                  color: themeProvider.isDarkMode
                      ? Colors.white54
                      : Colors.black45,
                )
                    : null,
                onTap: () {
                  // Navigate to profile page
                  Get.toNamed('/profile');
                  // Close drawer if on mobile
                  // if (sidebarProvider.isMobile) {
                  //   Navigator.of(Get.context!).pop();
                  // }
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}