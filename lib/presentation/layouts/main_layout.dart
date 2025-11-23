import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../core/providers/sidebar_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/search_provider.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/sidebar/sidebar.dart';
import '../widgets/topbar/topbar.dart';
import '../pages/dashboard/analytics_dashboard.dart';

class MainLayout extends StatefulWidget {
  final Widget? content;
  // 1. Add showTopbar parameter with default value true
  final bool showTopbar;

  const MainLayout({
    super.key,
    this.content,
    this.showTopbar = true, // Default to true
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  late AnimationController _sidebarAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _sidebarAnimation;
  late Animation<double> _contentAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentRoute = '';

  @override
  void initState() {
    super.initState();

    _sidebarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _sidebarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sidebarAnimationController,
      curve: Curves.easeInOut,
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeInOut,
    ));

    _sidebarAnimationController.forward();
    _contentAnimationController.forward();

    // Initialize current route
    _currentRoute = Get.currentRoute;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupRouteListener();
  }

  void _setupRouteListener() {
    // CORRECT: Use the routing object properly
    final currentRouteRx = Get.routing.current.obs; // This makes the current route observable in the context of the ever function
    ever(currentRouteRx, (String newRoute) {
      _handleRouteChange(newRoute);
    });
  }

  void _handleRouteChange(String newRoute) {
    if (newRoute != _currentRoute) {
      print('Route changed from $_currentRoute to $newRoute');

      // Use Future.microtask to ensure we're not in build phase
      Future.microtask(() {
        final searchProvider = Provider.of<SearchProvider>(context, listen: false);
        searchProvider.clearSearch();

        final sidebarProvider = Provider.of<SidebarProvider>(context, listen: false);
        sidebarProvider.setActiveRoute(newRoute);
      });

      _currentRoute = newRoute;
    }
  }

  @override
  void dispose() {
    _sidebarAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SidebarProvider, ThemeProvider>(
      builder: (context, sidebarProvider, themeProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            sidebarProvider.updateScreenSize(constraints.biggest);
            final isMobile = sidebarProvider.isMobile;

            return WillPopScope(
              onWillPop: () async {
                return true;
              },
              child: Scaffold(
                key: _scaffoldKey,
                drawer: isMobile ? _buildMobileDrawer(themeProvider) : null,
                body: Container(
                  decoration: BoxDecoration(
                    gradient: themeProvider.isDarkMode
                        ? AppTheme.darkBackgroundGradient
                        : AppTheme.backgroundGradient,
                  ),
                  child: isMobile
                      ? _buildMobileLayout(sidebarProvider, themeProvider)
                      : _buildDesktopLayout(sidebarProvider, themeProvider),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ... rest of your methods remain the same
  Widget _buildMobileDrawer(ThemeProvider themeProvider) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.isDarkMode
              ? AppTheme.darkBackgroundGradient
              : AppTheme.backgroundGradient,
        ),
        child: const Sidebar(),
      ),
    );
  }

  Widget _buildMobileLayout(SidebarProvider sidebarProvider, ThemeProvider themeProvider) {
    // 2. Conditionally add Topbar in mobile layout
    final topbar = widget.showTopbar
        ? [
      Topbar(
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      )
    ]
        : <Widget>[];

    return Column(
      children: [
        ...topbar, // Use the spread operator to include Topbar if showTopbar is true
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: themeProvider.isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.7),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: widget.content ?? const AnalyticsDashboard(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(SidebarProvider sidebarProvider, ThemeProvider themeProvider) {
    // 3. Conditionally add Topbar in desktop layout
    final topbar = widget.showTopbar
        ? [const Topbar()]
        : <Widget>[];

    return Row(
      children: [
        AnimatedBuilder(
          animation: _sidebarAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                -sidebarProvider.sidebarWidth * (1 - _sidebarAnimation.value),
                0,
              ),
              child: SizedBox(
                width: sidebarProvider.sidebarWidth,
                child: const Sidebar(),
              ),
            );
          },
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: _contentAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  sidebarProvider.sidebarWidth * (1 - _contentAnimation.value),
                  0,
                ),
                child: Column(
                  children: [
                    ...topbar, // Use the spread operator to include Topbar if showTopbar is true
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: themeProvider.isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.white.withOpacity(0.7),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: widget.content ?? const AnalyticsDashboard(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}