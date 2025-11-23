import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/sidebar_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';

class SidebarItem {
  final IconData icon;
  final String title;
  final String route;
  final bool isActive;

  const SidebarItem({
    required this.icon,
    required this.title,
    required this.route,
    this.isActive = false,
  });
}

class SidebarItemWidget extends StatefulWidget {
  final SidebarItem item;
  final bool isExpanded;
  final ThemeProvider themeProvider;

  const SidebarItemWidget({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.themeProvider,
  });

  @override
  State<SidebarItemWidget> createState() => _SidebarItemWidgetState();
}

class _SidebarItemWidgetState extends State<SidebarItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: widget.item.isActive
                    ? AppTheme.primaryColor.withValues(alpha: 0.1)
                    : _isHovered
                    ? widget.themeProvider.isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: widget.item.isActive
                    ? Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  width: 1,
                )
                    : null,
                boxShadow: widget.item.isActive
                    ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (widget.item.route.isNotEmpty) {
                      // Update the provider state
                      final sidebarProvider = Provider.of<SidebarProvider>(
                        context,
                        listen: false,
                      );
                      sidebarProvider.setActiveRoute(widget.item.route);

                      // Close drawer on mobile before navigating
                      if (sidebarProvider.isMobile) {
                        Navigator.of(context).pop();
                      }

                      // Navigate
                      Get.toNamed(widget.item.route);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.isExpanded ? 16 : 8,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        Container(
                          width: widget.isExpanded ? 40 : 32,
                          height: widget.isExpanded ? 40 : 32,
                          decoration: BoxDecoration(
                            color: widget.item.isActive
                                ? AppTheme.primaryColor
                                : _isHovered
                                ? widget.themeProvider.isDarkMode
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.05)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                                widget.isExpanded ? 10 : 8),
                          ),
                          child: Icon(
                            widget.item.icon,
                            size: widget.isExpanded ? 20 : 16,
                            color: widget.item.isActive
                                ? Colors.white
                                : widget.themeProvider.isDarkMode
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),

                        // Title
                        if (widget.isExpanded) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.item.title,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.customTextStyle(
                                color: widget.item.isActive
                                    ? AppTheme.primaryColor
                                    : widget.themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 14,
                                fontWeight: widget.item.isActive
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}