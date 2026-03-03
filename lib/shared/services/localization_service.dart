import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  String _currentLanguage = 'English';
  
  String get currentLanguage => _currentLanguage;
  
  // Language code mapping
  Map<String, String> get languageCodes => {
    'English': 'en',
    'Tamil': 'ta',
  };
  
  // Initialize localization service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? 'English';
    notifyListeners();
  }
  
  // Change language
  Future<void> changeLanguage(String language) async {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language);
      notifyListeners();
    }
  }
  
  // Get localized string
  String getString(String key) {
    if (_currentLanguage == 'Tamil') {
      return _tamilStrings[key] ?? _englishStrings[key] ?? key;
    }
    return _englishStrings[key] ?? key;
  }
  
  // English strings
  static const Map<String, String> _englishStrings = {
    // Navigation
    'stores': 'Stores',
    'favorites': 'Favorites',
    'orders': 'Orders',
    'profile': 'Profile',
    
    // Home/Stores
    'smart_vending': 'Smart Grocery',
    'find_nearby_stores': 'Find nearby grocery stores',
    'search_stores': 'Search stores...',
    'available_stores': 'Available Stores',
    'open_now': 'Open Now',
    'closed': 'Closed',
    'away': 'away',
    'view_products': 'View Products',
    
    // Favorites
    'my_favorites': 'My Favorites',
    'recently_viewed': 'Recently Viewed',
    'price_alerts': 'Price Alerts',
    'no_favorites': 'No favorites yet',
    'start_shopping': 'Start shopping to add favorites',
    'no_recent_items': 'No recent items',
    'browse_products': 'Browse products to see recent items',
    'no_price_alerts': 'No price alerts set',
    'set_alerts': 'Set alerts for price drops',
    'remove_from_favorites': 'Remove from favorites',
    'view_product': 'View Product',
    'set_price_alert': 'Set Price Alert',
    'remove_alert': 'Remove Alert',
    'enable_all_alerts': 'Enable All Alerts',
    'disable_all_alerts': 'Disable All Alerts',
    'clear_history': 'Clear History',
    'price_drop_alert': 'Price Drop Alert',
    'desired_price': 'Desired Price',
    'set_alert': 'Set Alert',
    'cancel': 'Cancel',
    
    // Orders
    'order_history': 'Order History',
    'current_orders': 'Current Orders',
    'past_orders': 'Past Orders',
    'no_orders': 'No orders yet',
    'place_first_order': 'Place your first order to see it here',
    'no_current_orders': 'No current orders',
    'no_past_orders': 'No past orders',
    'order': 'Order',
    'items': 'items',
    'reorder': 'Reorder',
    'track_order': 'Track Order',
    'view_receipt': 'View Receipt',
    'confirmed': 'Confirmed',
    'preparing': 'Preparing',
    'ready': 'Ready',
    'delivered': 'Delivered',
    'cancelled': 'Cancelled',
    
    // Profile
    'my_profile': 'My Profile',
    'edit_profile': 'Edit Profile',
    'manage_addresses': 'Manage Addresses',
    'payment_methods': 'Payment Methods',
    'notifications': 'Notifications',
    'settings': 'Settings',
    'help_support': 'Help & Support',
    'logout': 'Logout',
    
    // Settings
    'appearance': 'Appearance',
    'theme': 'Theme',
    'language': 'Language',
    'account_security': 'Account & Security',
    'change_password': 'Change Password',
    'update_security': 'Update your security settings',
    'about': 'About',
    'terms_conditions': 'Terms & Conditions',
    'privacy_policy': 'Privacy Policy',
    'dark_mode': 'Dark Mode',
    'light_mode': 'Light Mode',
    'system_default': 'System Default',
    
    // Product Browsing
    'products': 'Products',
    'search_products': 'Search products...',
    'all_categories': 'All Categories',
    'add_to_cart': 'Add to Cart',
    'out_of_stock': 'Out of Stock',
    'in_stock': 'In Stock',
    'low_stock': 'Low Stock',
    
    // Cart
    'shopping_cart': 'Shopping Cart',
    'cart_empty': 'Your cart is empty',
    'continue_shopping': 'Continue Shopping',
    'subtotal': 'Subtotal',
    'total': 'Total',
    'checkout': 'Checkout',
    'remove': 'Remove',
    'quantity': 'Quantity',
    
    // Checkout
    'order_summary': 'Order Summary',
    'delivery_address': 'Delivery Address',
    'payment_method': 'Payment Method',
    'place_order': 'Place Order',
    'order_placed': 'Order Placed Successfully!',
    
    // Common
    'save': 'Save',
    'edit': 'Edit',
    'delete': 'Delete',
    'add': 'Add',
    'update': 'Update',
    'confirm': 'Confirm',
    'back': 'Back',
    'next': 'Next',
    'done': 'Done',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'retry': 'Retry',
    'close': 'Close',
    'ok': 'OK',
    'yes': 'Yes',
    'no': 'No',
  };
  
  // Tamil strings
  static const Map<String, String> _tamilStrings = {
    // Navigation
    'stores': 'கடைகள்',
    'favorites': 'விருப்பங்கள்',
    'orders': 'ஆர்டர்கள்',
    'profile': 'சுயவிவரம்',
    
    // Home/Stores
    'smart_vending': 'ஸ்மார்ட் கிராசரி',
    'find_nearby_stores': 'அருகிலுள்ள கிராசரி கடைகளைக் கண்டறியவும்',
    'search_stores': 'கடைகளைத் தேடவும்...',
    'available_stores': 'கிடைக்கும் கடைகள்',
    'open_now': 'இப்போது திறந்துள்ளது',
    'closed': 'மூடப்பட்டுள்ளது',
    'away': 'தூரம்',
    'view_products': 'பொருட்களைப் பார்க்கவும்',
    
    // Favorites
    'my_favorites': 'என் விருப்பங்கள்',
    'recently_viewed': 'சமீபத்தில் பார்த்தவை',
    'price_alerts': 'விலை அலர்ட்கள்',
    'no_favorites': 'இன்னும் விருப்பங்கள் இல்லை',
    'start_shopping': 'விருப்பங்களைச் சேர்க்க ஷாப்பிங் தொடங்கவும்',
    'no_recent_items': 'சமீபத்திய பொருட்கள் இல்லை',
    'browse_products': 'சமீபத்திய பொருட்களைப் பார்க்க பொருட்களை உலாவவும்',
    'no_price_alerts': 'விலை அலர்ட்கள் அமைக்கப்படவில்லை',
    'set_alerts': 'விலை குறைவுக்கான அலர்ட்களை அமைக்கவும்',
    'remove_from_favorites': 'விருப்பங்களிலிருந்து நீக்கவும்',
    'view_product': 'பொருளைப் பார்க்கவும்',
    'set_price_alert': 'விலை அலர்ட் அமைக்கவும்',
    'remove_alert': 'அலர்ட்டை நீக்கவும்',
    'enable_all_alerts': 'அனைத்து அலர்ட்களையும் இயக்கவும்',
    'disable_all_alerts': 'அனைத்து அலர்ட்களையும் முடக்கவும்',
    'clear_history': 'வரலாற்றை அழிக்கவும்',
    'price_drop_alert': 'விலை குறைவு அலர்ட்',
    'desired_price': 'விரும்பும் விலை',
    'set_alert': 'அலர்ட் அமைக்கவும்',
    'cancel': 'ரத்து செய்',
    
    // Orders
    'order_history': 'ஆர்டர் வரலாறு',
    'current_orders': 'தற்போதைய ஆர்டர்கள்',
    'past_orders': 'கடந்த ஆர்டர்கள்',
    'no_orders': 'இன்னும் ஆர்டர்கள் இல்லை',
    'place_first_order': 'உங்கள் முதல் ஆர்டரை இங்கே பார்க்க வைக்கவும்',
    'no_current_orders': 'தற்போதைய ஆர்டர்கள் இல்லை',
    'no_past_orders': 'கடந்த ஆர்டர்கள் இல்லை',
    'order': 'ஆர்டர்',
    'items': 'பொருட்கள்',
    'reorder': 'மீண்டும் ஆர்டர் செய்',
    'track_order': 'ஆர்டரைக் கண்காணிக்கவும்',
    'view_receipt': 'ரசீதைப் பார்க்கவும்',
    'confirmed': 'உறுதிப்படுத்தப்பட்டது',
    'preparing': 'தயாரிக்கப்படுகிறது',
    'ready': 'தயார்',
    'delivered': 'வழங்கப்பட்டது',
    'cancelled': 'ரத்து செய்யப்பட்டது',
    
    // Profile
    'my_profile': 'என் சுயவிவரம்',
    'edit_profile': 'சுயவிவரத்தைத் திருத்தவும்',
    'manage_addresses': 'முகவரிகளை நிர்வகிக்கவும்',
    'payment_methods': 'கட்டண முறைகள்',
    'notifications': 'அறிவிப்புகள்',
    'settings': 'அமைப்புகள்',
    'help_support': 'உதவி & ஆதரவு',
    'logout': 'வெளியேறு',
    
    // Settings
    'appearance': 'தோற்றம்',
    'theme': 'தீம்',
    'language': 'மொழி',
    'account_security': 'கணக்கு & பாதுகாப்பு',
    'change_password': 'கடவுச்சொல்லை மாற்றவும்',
    'update_security': 'உங்கள் பாதுகாப்பு அமைப்புகளை புதுப்பிக்கவும்',
    'about': 'பற்றி',
    'terms_conditions': 'விதிமுறைகள் & நிபந்தனைகள்',
    'privacy_policy': 'தனியுரிமை கொள்கை',
    'dark_mode': 'டார்க் மோட்',
    'light_mode': 'லைட் மோட்',
    'system_default': 'சிஸ்டம் இயல்புநிலை',
    
    // Product Browsing
    'products': 'பொருட்கள்',
    'search_products': 'பொருட்களைத் தேடவும்...',
    'all_categories': 'அனைத்து வகைகளும்',
    'add_to_cart': 'கார்ட்டில் சேர்க்கவும்',
    'out_of_stock': 'கையிருப்பில் இல்லை',
    'in_stock': 'கையிருப்பில் உள்ளது',
    'low_stock': 'குறைவான கையிருப்பு',
    
    // Cart
    'shopping_cart': 'ஷாப்பிங் கார்ட்',
    'cart_empty': 'உங்கள் கார்ட் காலியாக உள்ளது',
    'continue_shopping': 'ஷாப்பிங்கைத் தொடரவும்',
    'subtotal': 'துணைத் தொகை',
    'total': 'மொத்தம்',
    'checkout': 'செக்அவுட்',
    'remove': 'நீக்கவும்',
    'quantity': 'அளவு',
    
    // Checkout
    'order_summary': 'ஆர்டர் சுருக்கம்',
    'delivery_address': 'டெலிவரி முகவரி',
    'payment_method': 'கட்டண முறை',
    'place_order': 'ஆர்டர் வைக்கவும்',
    'order_placed': 'ஆர்டர் வெற்றிகரமாக வைக்கப்பட்டது!',
    
    // Common
    'save': 'சேமிக்கவும்',
    'edit': 'திருத்தவும்',
    'delete': 'அழிக்கவும்',
    'add': 'சேர்க்கவும்',
    'update': 'புதுப்பிக்கவும்',
    'confirm': 'உறுதிப்படுத்தவும்',
    'back': 'பின்',
    'next': 'அடுத்து',
    'done': 'முடிந்தது',
    'loading': 'ஏற்றப்படுகிறது...',
    'error': 'பிழை',
    'success': 'வெற்றி',
    'retry': 'மீண்டும் முயற்சிக்கவும்',
    'close': 'மூடவும்',
    'ok': 'சரி',
    'yes': 'ஆம்',
    'no': 'இல்லை',
  };
}