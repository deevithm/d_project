import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';

/// Accessibility helper utilities for the app
class AccessibilityHelper {
  /// Provides semantic labels for screen reader users
  static Map<String, String> semanticLabels = {
    'store_card': 'Grocery store option',
    'product_card': 'Product option',
    'add_to_cart': 'Add item to shopping cart',
    'cart_item': 'Cart item',
    'checkout_button': 'Proceed to checkout',
    'navigation_tab': 'Navigation tab',
    'filter_chip': 'Filter option',
    'search_field': 'Search for products',
    'quantity_input': 'Quantity selector',
    'price_display': 'Price information',
    'status_indicator': 'Status indicator',
    'order_card': 'Order history item',
    'back_button': 'Go back to previous screen',
    'menu_button': 'Open menu options',
    'refresh_button': 'Refresh content',
  };

  /// Provides hints for interactive elements
  static Map<String, String> semanticHints = {
    'store_card': 'Tap to view products in this grocery store',
    'product_card': 'Tap to view product details',
    'add_to_cart': 'Double tap to add this item to your cart',
    'cart_item': 'Swipe to remove from cart',
    'checkout_button': 'Tap to proceed with payment',
    'navigation_tab': 'Tap to navigate to this section',
    'filter_chip': 'Tap to filter products by this category',
    'search_field': 'Enter text to search for products',
    'quantity_input': 'Use plus and minus buttons to adjust quantity',
    'back_button': 'Tap to return to previous screen',
    'refresh_button': 'Tap to reload content',
  };

  /// Creates accessible buttons with proper semantics
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    required String semanticLabel,
    String? semanticHint,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: onPressed != null,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  /// Creates accessible cards with proper navigation semantics
  static Widget accessibleCard({
    required Widget child,
    required VoidCallback? onTap,
    required String semanticLabel,
    String? semanticHint,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: onTap != null,
      enabled: onTap != null,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  /// Creates accessible text with proper reading order
  static Widget accessibleText({
    required String text,
    TextStyle? style,
    String? semanticLabel,
    bool isHeader = false,
    bool isLiveRegion = false,
    TextAlign? textAlign,
  }) {
    return Semantics(
      label: semanticLabel ?? text,
      header: isHeader,
      liveRegion: isLiveRegion,
      excludeSemantics: false,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
      ),
    );
  }

  /// Creates accessible form fields with proper labeling
  static Widget accessibleFormField({
    required Widget child,
    required String label,
    String? hint,
    String? error,
    bool required = false,
  }) {
    return Semantics(
      label: required ? '$label, required field' : label,
      hint: hint,
      textField: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (error != null)
            Semantics(
              liveRegion: true,
              child: Text(
                error,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }

  /// Provides haptic feedback for interactions
  static void provideFeedback({
    HapticFeedbackType type = HapticFeedbackType.lightImpact,
  }) {
    switch (type) {
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
        break;
    }
  }

  /// Creates focus order for tab navigation
  static Widget focusableWidget({
    required Widget child,
    required FocusNode focusNode,
    VoidCallback? onFocusChange,
    bool autofocus = false,
  }) {
    return Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          HapticFeedback.selectionClick();
        }
        onFocusChange?.call();
      },
      child: child,
    );
  }

  /// Announces changes to screen readers
  static void announce(String message) {
    // This will be announced by screen readers
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Creates accessible loading indicators
  static Widget accessibleLoadingIndicator({
    String? label,
    double? value,
  }) {
    return Semantics(
      label: label ?? 'Loading content, please wait',
      liveRegion: true,
      child: CircularProgressIndicator(
        value: value,
        semanticsLabel: label ?? 'Loading',
        semanticsValue: value != null ? '${(value * 100).round()}% complete' : null,
      ),
    );
  }

  /// Creates accessible navigation elements
  static Widget accessibleNavigation({
    required Widget child,
    required String label,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: isSelected ? '$label, selected' : label,
      selected: isSelected,
      button: true,
      enabled: onTap != null,
      child: child,
    );
  }

  /// Creates accessible images with alt text
  static Widget accessibleImage({
    required Widget image,
    required String altText,
    bool isDecorative = false,
  }) {
    if (isDecorative) {
      return ExcludeSemantics(child: image);
    }
    
    return Semantics(
      label: altText,
      image: true,
      child: image,
    );
  }

  /// Creates accessible alerts and notifications
  static Widget accessibleAlert({
    required Widget child,
    required String message,
    bool isError = false,
  }) {
    return Semantics(
      label: isError ? 'Error: $message' : 'Alert: $message',
      liveRegion: true,
      child: child,
    );
  }
}

/// Enum for haptic feedback types
enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
}

/// Responsive breakpoints for different screen sizes
class ResponsiveBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;

  /// Check if the screen size is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  /// Check if the screen size is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  /// Check if the screen size is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  /// Get the number of columns for grid layouts
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }

  /// Get appropriate padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(16);
    if (isTablet(context)) return const EdgeInsets.all(24);
    return const EdgeInsets.all(32);
  }

  /// Get appropriate font size based on screen size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) return baseFontSize;
    if (isTablet(context)) return baseFontSize * 1.1;
    return baseFontSize * 1.2;
  }
}

/// Accessibility theme configuration
class AccessibilityTheme {
  /// High contrast colors for accessibility
  static const Map<String, Color> highContrastColors = {
    'primary': Color(0xFF000080),
    'secondary': Color(0xFF800080),
    'surface': Color(0xFFFFFFFF),
    'background': Color(0xFFFFFFFF),
    'error': Color(0xFFCC0000),
    'success': Color(0xFF006600),
    'warning': Color(0xFF996600),
    'textPrimary': Color(0xFF000000),
    'textSecondary': Color(0xFF333333),
    'border': Color(0xFF666666),
  };

  /// Large text theme for accessibility
  static TextTheme getLargeTextTheme(TextTheme baseTheme) {
    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(fontSize: (baseTheme.displayLarge?.fontSize ?? 57) * 1.3),
      displayMedium: baseTheme.displayMedium?.copyWith(fontSize: (baseTheme.displayMedium?.fontSize ?? 45) * 1.3),
      displaySmall: baseTheme.displaySmall?.copyWith(fontSize: (baseTheme.displaySmall?.fontSize ?? 36) * 1.3),
      headlineLarge: baseTheme.headlineLarge?.copyWith(fontSize: (baseTheme.headlineLarge?.fontSize ?? 32) * 1.3),
      headlineMedium: baseTheme.headlineMedium?.copyWith(fontSize: (baseTheme.headlineMedium?.fontSize ?? 28) * 1.3),
      headlineSmall: baseTheme.headlineSmall?.copyWith(fontSize: (baseTheme.headlineSmall?.fontSize ?? 24) * 1.3),
      titleLarge: baseTheme.titleLarge?.copyWith(fontSize: (baseTheme.titleLarge?.fontSize ?? 22) * 1.3),
      titleMedium: baseTheme.titleMedium?.copyWith(fontSize: (baseTheme.titleMedium?.fontSize ?? 16) * 1.3),
      titleSmall: baseTheme.titleSmall?.copyWith(fontSize: (baseTheme.titleSmall?.fontSize ?? 14) * 1.3),
      bodyLarge: baseTheme.bodyLarge?.copyWith(fontSize: (baseTheme.bodyLarge?.fontSize ?? 16) * 1.3),
      bodyMedium: baseTheme.bodyMedium?.copyWith(fontSize: (baseTheme.bodyMedium?.fontSize ?? 14) * 1.3),
      bodySmall: baseTheme.bodySmall?.copyWith(fontSize: (baseTheme.bodySmall?.fontSize ?? 12) * 1.3),
      labelLarge: baseTheme.labelLarge?.copyWith(fontSize: (baseTheme.labelLarge?.fontSize ?? 14) * 1.3),
      labelMedium: baseTheme.labelMedium?.copyWith(fontSize: (baseTheme.labelMedium?.fontSize ?? 12) * 1.3),
      labelSmall: baseTheme.labelSmall?.copyWith(fontSize: (baseTheme.labelSmall?.fontSize ?? 11) * 1.3),
    );
  }

  /// Get minimum touch target size for accessibility
  static const double minimumTouchTargetSize = 48.0;

  /// Ensure touch targets meet accessibility guidelines
  static BoxConstraints getAccessibleConstraints() {
    return const BoxConstraints(
      minWidth: minimumTouchTargetSize,
      minHeight: minimumTouchTargetSize,
    );
  }
}