import 'package:flutter/material.dart';

/// Responsive design utilities for adaptive layouts
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 768) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Responsive container that adapts to screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? mobileMaxWidth;
  final double? tabletMaxWidth;
  final double? desktopMaxWidth;
  final EdgeInsetsGeometry? mobilePadding;
  final EdgeInsetsGeometry? tabletPadding;
  final EdgeInsetsGeometry? desktopPadding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileMaxWidth,
    this.tabletMaxWidth,
    this.desktopMaxWidth,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth;
        EdgeInsetsGeometry padding;

        if (constraints.maxWidth >= 1024) {
          maxWidth = desktopMaxWidth ?? 1200;
          padding = desktopPadding ?? const EdgeInsets.all(32);
        } else if (constraints.maxWidth >= 768) {
          maxWidth = tabletMaxWidth ?? 800;
          padding = tabletPadding ?? const EdgeInsets.all(24);
        } else {
          maxWidth = mobileMaxWidth ?? constraints.maxWidth;
          padding = mobilePadding ?? const EdgeInsets.all(16);
        }

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Responsive grid that adapts column count to screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;
        
        if (constraints.maxWidth >= 1024) {
          columns = desktopColumns;
        } else if (constraints.maxWidth >= 768) {
          columns = tabletColumns;
        } else {
          columns = mobileColumns;
        }

        return GridView.builder(
          padding: padding,
          physics: physics,
          shrinkWrap: shrinkWrap,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// Responsive text that scales with screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double mobileSize;
  final double? tabletSize;
  final double? desktopSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText({
    super.key,
    required this.text,
    this.style,
    required this.mobileSize,
    this.tabletSize,
    this.desktopSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize;
        
        if (constraints.maxWidth >= 1024) {
          fontSize = desktopSize ?? tabletSize ?? mobileSize * 1.2;
        } else if (constraints.maxWidth >= 768) {
          fontSize = tabletSize ?? mobileSize * 1.1;
        } else {
          fontSize = mobileSize;
        }

        return Text(
          text,
          style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

/// Responsive spacing that adapts to screen size
class ResponsiveSpacing {
  static double getSpacing(BuildContext context, {
    double mobile = 8.0,
    double? tablet,
    double? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= 1024) {
      return desktop ?? tablet ?? mobile * 1.5;
    } else if (width >= 768) {
      return tablet ?? mobile * 1.25;
    } else {
      return mobile;
    }
  }

  static EdgeInsets getPadding(BuildContext context, {
    EdgeInsets mobile = const EdgeInsets.all(16),
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= 1024) {
      return desktop ?? tablet ?? mobile * 2;
    } else if (width >= 768) {
      return tablet ?? mobile * 1.5;
    } else {
      return mobile;
    }
  }
}

/// Extension for EdgeInsets multiplication
extension EdgeInsetsMultiply on EdgeInsets {
  EdgeInsets operator *(double multiplier) {
    return EdgeInsets.fromLTRB(
      left * multiplier,
      top * multiplier,
      right * multiplier,
      bottom * multiplier,
    );
  }
}

/// Responsive navigation that changes layout based on screen size
class ResponsiveNavigation extends StatelessWidget {
  final List<ResponsiveNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const ResponsiveNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use bottom navigation for mobile, side navigation for desktop
        if (constraints.maxWidth >= 1024) {
          return _buildSideNavigation();
        } else {
          return _buildBottomNavigation();
        }
      },
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      items: items.map((item) => BottomNavigationBarItem(
        icon: Icon(item.icon),
        label: item.label,
      )).toList(),
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
    );
  }

  Widget _buildSideNavigation() {
    return NavigationRail(
      destinations: items.map((item) => NavigationRailDestination(
        icon: Icon(item.icon),
        label: Text(item.label),
      )).toList(),
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: backgroundColor,
      selectedIconTheme: IconThemeData(color: selectedItemColor),
      unselectedIconTheme: IconThemeData(color: unselectedItemColor),
      labelType: NavigationRailLabelType.all,
    );
  }
}

/// Navigation item for responsive navigation
class ResponsiveNavigationItem {
  final IconData icon;
  final String label;

  const ResponsiveNavigationItem({
    required this.icon,
    required this.label,
  });
}

/// Responsive dialog that adapts size to screen
class ResponsiveDialog extends StatelessWidget {
  final Widget child;
  final String? title;
  final EdgeInsetsGeometry? padding;
  final double? mobileMaxWidth;
  final double? tabletMaxWidth;
  final double? desktopMaxWidth;

  const ResponsiveDialog({
    super.key,
    required this.child,
    this.title,
    this.padding,
    this.mobileMaxWidth,
    this.tabletMaxWidth,
    this.desktopMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth;
        bool isFullScreen = false;

        if (constraints.maxWidth >= 1024) {
          maxWidth = desktopMaxWidth ?? 600;
        } else if (constraints.maxWidth >= 768) {
          maxWidth = tabletMaxWidth ?? 500;
        } else {
          maxWidth = mobileMaxWidth ?? constraints.maxWidth * 0.9;
          isFullScreen = constraints.maxWidth < 480;
        }

        if (isFullScreen) {
          return Dialog.fullscreen(
            child: Scaffold(
              appBar: title != null ? AppBar(title: Text(title!)) : null,
              body: Padding(
                padding: padding ?? const EdgeInsets.all(16),
                child: child,
              ),
            ),
          );
        }

        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                  ],
                  child,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}