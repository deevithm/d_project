import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/store_selection/store_selection_screen.dart';
import '../../features/order_history/order_history_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../services/localization_service.dart';
import '../widgets/responsive/responsive_layout.dart';
import '../utils/accessibility_helper.dart';
import '../../core/constants.dart';
import '../widgets/cart_fab.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> 
    with TickerProviderStateMixin {
  late int _currentIndex;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<NavigationItem> _getNavigationItems(LocalizationService localizationService) {
    return [
      NavigationItem(
        icon: MdiIcons.store,
        label: localizationService.getString('stores'),
        screen: const StoreSelectionScreen(),
      ),
      NavigationItem(
        icon: MdiIcons.receiptText,
        label: localizationService.getString('orders'),
        screen: const OrderHistoryScreen(),
      ),
      NavigationItem(
        icon: MdiIcons.heart,
        label: localizationService.getString('favorites'),
        screen: const FavoritesScreen(),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        final navigationItems = _getNavigationItems(localizationService);
        
        return PopScope(
          canPop: _currentIndex == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && _currentIndex != 0) {
              // Navigate to home (store selection) screen instead of popping
              setState(() {
                _currentIndex = 0;
                _pageController.jumpToPage(0);
              });
            }
          },
          child: Scaffold(
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: navigationItems.map((item) => item.screen).toList(),
              ),
            ),
            floatingActionButton: const CartFAB(),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            bottomNavigationBar: _buildBottomNavigationBar(navigationItems),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(List<NavigationItem> navigationItems) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          selectedLabelStyle: TextStyle(
            fontSize: ResponsiveBreakpoints.getResponsiveFontSize(context, 12),
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: ResponsiveBreakpoints.getResponsiveFontSize(context, 12),
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          items: navigationItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == _currentIndex;
            
            return BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: ResponsiveBreakpoints.getResponsivePadding(context).copyWith(
                  left: ResponsiveSpacing.getSpacing(context, mobile: 8, tablet: 10, desktop: 12),
                  right: ResponsiveSpacing.getSpacing(context, mobile: 8, tablet: 10, desktop: 12),
                  top: ResponsiveSpacing.getSpacing(context, mobile: 8, tablet: 10, desktop: 12),
                  bottom: ResponsiveSpacing.getSpacing(context, mobile: 8, tablet: 10, desktop: 12),
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary.withValues(alpha: 0.1) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: ResponsiveSpacing.getSpacing(context, mobile: 24, tablet: 26, desktop: 28),
                ),
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      // Update the route to reflect the current tab
      _updateRoute(index);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _updateRoute(index);
  }

  void _updateRoute(int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.stores);
        break;
      case 1:
        context.go(AppRoutes.orders);
        break;
      case 2:
        context.go(AppRoutes.favorites);
        break;
    }
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final Widget screen;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}