// lib/core/providers/sidebar_provider.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum SidebarState {
  expanded,
  collapsed,
  hidden,
}

class SidebarProvider extends ChangeNotifier {
  static const String _sidebarKey = 'sidebar_state';
  // Use 'late' Box, assuming initHive is called before any box access.
  late Box _box;

  SidebarState _sidebarState = SidebarState.expanded;
  bool _isMobile = false;

  String _activeRoute = '';

  // --- Getters ---
  SidebarState get sidebarState => _sidebarState;
  bool get isExpanded => _sidebarState == SidebarState.expanded;
  bool get isCollapsed => _sidebarState == SidebarState.collapsed;
  bool get isHidden => _sidebarState == SidebarState.hidden;
  bool get isMobile => _isMobile;

  String get activeRoute => _activeRoute;

  // --- Constructor ---
  SidebarProvider() {
    // 1. Initialize _activeRoute with the current route before Hive initialization
    // Get.currentRoute will hold the route the app was launched on.
    _activeRoute = Get.currentRoute;

    // 2. Process the initial route immediately
    // Call setActiveRoute to correctly map detail/add pages to their parents
    setActiveRoute(_activeRoute);

    // 3. Continue with existing Hive initialization
    _initHive();
  }

  // --- Initialization ---
  Future<void> _initHive() async {
    // Ensure you call Hive.init() and open the box elsewhere in your app startup
    _box = Hive.box('settings');
    _loadSidebarState();
  }

  void _loadSidebarState() {
    final savedState = _box.get(_sidebarKey, defaultValue: 'expanded');
    switch (savedState) {
      case 'collapsed':
        _sidebarState = SidebarState.collapsed;
        break;
      case 'hidden':
        _sidebarState = SidebarState.hidden;
        break;
      default:
        _sidebarState = SidebarState.expanded;
    }
    notifyListeners();
  }

  // --- State Management Methods ---
  Future<void> setSidebarState(SidebarState state) async {
    _sidebarState = state;
    await _box.put(_sidebarKey, state.name);
    notifyListeners();
  }

  /**
   * Updates the active route for highlighting the correct item in the sidebar.
   * Handles both exact matches and mapping sub-routes to a parent route.
   */
  void setActiveRoute(String route) {
    String parentRoute = route;

    // 1. Handle exact matches first
    if (route == '/analytics' ||
        route == '/qualities' ||
        route == '/master-data' ||
        route == '/calendar') {
      _activeRoute = route;
      notifyListeners();
      return;
    }

    // 2. Handle detail and add routes by mapping them back to their parents
    if (route.startsWith('/order-detail') || route == '/add-order') {
      parentRoute = '/analytics';
    } else if (route.startsWith('/quality-detail') || route == '/add-quality') {
      parentRoute = '/qualities';
    } else if (route.startsWith('/master-data-detail') || route == '/add-master-data') {
      parentRoute = '/master-data';
    } else if (route.startsWith('/calendar')) {
      // This is a catch-all for /calendar/subroute but since /calendar is handled above,
      // this only catches sub-routes if they exist.
      parentRoute = '/calendar';
    } else {
      // Default to analytics if no match found
      parentRoute = '/analytics';
    }

    // Only update if different to avoid unnecessary rebuilds
    if (_activeRoute != parentRoute) {
      _activeRoute = parentRoute;
      notifyListeners();
    }
  }

  void toggleSidebar() {
    if (_isMobile) {
      // On mobile, toggle between hidden and expanded (only in the drawer)
      setSidebarState(_sidebarState == SidebarState.hidden
          ? SidebarState.expanded
          : SidebarState.hidden);
    } else {
      // On desktop, toggle between expanded and collapsed
      setSidebarState(_sidebarState == SidebarState.expanded
          ? SidebarState.collapsed
          : SidebarState.expanded);
    }
  }

  void updateScreenSize(Size size) {
    final wasMobile = _isMobile;
    // Define the mobile breakpoint (e.g., 768px)
    _isMobile = size.width < 768;

    if (wasMobile != _isMobile) {
      if (_isMobile) {
        // Transition to mobile: hide sidebar by default
        if (_sidebarState != SidebarState.hidden) {
          setSidebarState(SidebarState.hidden);
        }
      } else {
        // Transition to desktop: expand sidebar by default
        if (_sidebarState == SidebarState.hidden) {
          setSidebarState(SidebarState.expanded);
        }
      }
    }
  }

  double get sidebarWidth {
    switch (_sidebarState) {
      case SidebarState.expanded:
        return 280;
      case SidebarState.collapsed:
        return 122;
      case SidebarState.hidden:
        return 0;
    }
  }
}