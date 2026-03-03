import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class NotificationService extends ChangeNotifier {
  static const String _pushNotificationsKey = 'push_notifications';
  static const String _emailNotificationsKey = 'email_notifications';
  static const String _smsNotificationsKey = 'sms_notifications';
  static const String _orderUpdatesKey = 'order_updates';
  static const String _promotionsKey = 'promotions';
  static const String _priceAlertsKey = 'price_alerts';
  static const String _restockAlertsKey = 'restock_alerts';
  static const String _systemUpdatesKey = 'system_updates';

  // Notification preferences
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _orderUpdates = true;
  bool _promotions = true;
  bool _priceAlerts = true;
  bool _restockAlerts = true;
  bool _systemUpdates = false;

  // Getters
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get smsNotifications => _smsNotifications;
  bool get orderUpdates => _orderUpdates;
  bool get promotions => _promotions;
  bool get priceAlerts => _priceAlerts;
  bool get restockAlerts => _restockAlerts;
  bool get systemUpdates => _systemUpdates;

  // Initialize the service
  Future<void> initialize() async {
    await _loadPreferences();
  }

  // Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    _pushNotifications = prefs.getBool(_pushNotificationsKey) ?? true;
    _emailNotifications = prefs.getBool(_emailNotificationsKey) ?? true;
    _smsNotifications = prefs.getBool(_smsNotificationsKey) ?? false;
    _orderUpdates = prefs.getBool(_orderUpdatesKey) ?? true;
    _promotions = prefs.getBool(_promotionsKey) ?? true;
    _priceAlerts = prefs.getBool(_priceAlertsKey) ?? true;
    _restockAlerts = prefs.getBool(_restockAlertsKey) ?? true;
    _systemUpdates = prefs.getBool(_systemUpdatesKey) ?? false;
    
    notifyListeners();
  }

  // Save preference to SharedPreferences
  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Toggle push notifications
  Future<void> togglePushNotifications(bool value) async {
    _pushNotifications = value;
    await _savePreference(_pushNotificationsKey, value);
    notifyListeners();
    
    if (value) {
      await _requestNotificationPermission();
    }
  }

  // Toggle email notifications
  Future<void> toggleEmailNotifications(bool value) async {
    _emailNotifications = value;
    await _savePreference(_emailNotificationsKey, value);
    notifyListeners();
  }

  // Toggle SMS notifications
  Future<void> toggleSmsNotifications(bool value) async {
    _smsNotifications = value;
    await _savePreference(_smsNotificationsKey, value);
    notifyListeners();
  }

  // Toggle order updates
  Future<void> toggleOrderUpdates(bool value) async {
    _orderUpdates = value;
    await _savePreference(_orderUpdatesKey, value);
    notifyListeners();
  }

  // Toggle promotions
  Future<void> togglePromotions(bool value) async {
    _promotions = value;
    await _savePreference(_promotionsKey, value);
    notifyListeners();
  }

  // Toggle price alerts
  Future<void> togglePriceAlerts(bool value) async {
    _priceAlerts = value;
    await _savePreference(_priceAlertsKey, value);
    notifyListeners();
  }

  // Toggle restock alerts
  Future<void> toggleRestockAlerts(bool value) async {
    _restockAlerts = value;
    await _savePreference(_restockAlertsKey, value);
    notifyListeners();
  }

  // Toggle system updates
  Future<void> toggleSystemUpdates(bool value) async {
    _systemUpdates = value;
    await _savePreference(_systemUpdatesKey, value);
    notifyListeners();
  }

  // Enable all notifications
  Future<void> enableAllNotifications() async {
    await togglePushNotifications(true);
    await toggleEmailNotifications(true);
    await toggleOrderUpdates(true);
    await togglePromotions(true);
    await togglePriceAlerts(true);
    await toggleRestockAlerts(true);
    await toggleSystemUpdates(true);
  }

  // Disable all notifications
  Future<void> disableAllNotifications() async {
    await togglePushNotifications(false);
    await toggleEmailNotifications(false);
    await toggleSmsNotifications(false);
    await toggleOrderUpdates(false);
    await togglePromotions(false);
    await togglePriceAlerts(false);
    await toggleRestockAlerts(false);
    await toggleSystemUpdates(false);
  }

  // Request notification permission (mock implementation)
  Future<void> _requestNotificationPermission() async {
    // In a real app, you would use packages like:
    // - firebase_messaging for push notifications
    // - permission_handler for permissions
    // - flutter_local_notifications for local notifications
    
    // Mock implementation
    debugPrint('Requesting notification permission...');
    // Simulate permission request delay
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('Notification permission granted');
  }

  // Send a test notification (mock implementation)
  Future<void> sendTestNotification() async {
    if (!_pushNotifications) {
      debugPrint('Push notifications are disabled');
      return;
    }

    // Mock notification sending
    debugPrint('Sending test notification...');
    await Future.delayed(const Duration(milliseconds: 1000));
    debugPrint('Test notification sent successfully');
  }

  // Schedule a notification (mock implementation)
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? type,
  }) async {
    // Check if the notification type is enabled
    bool isEnabled = false;
    switch (type) {
      case 'order':
        isEnabled = _orderUpdates;
        break;
      case 'promotion':
        isEnabled = _promotions;
        break;
      case 'price_alert':
        isEnabled = _priceAlerts;
        break;
      case 'restock':
        isEnabled = _restockAlerts;
        break;
      case 'system':
        isEnabled = _systemUpdates;
        break;
      default:
        isEnabled = _pushNotifications;
    }

    if (!isEnabled || !_pushNotifications) {
      debugPrint('Notification type "$type" is disabled');
      return;
    }

    // Mock scheduling
    debugPrint('Scheduling notification: $title - $body for $scheduledTime');
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('Notification scheduled successfully');
  }

  // Get notification statistics (mock implementation)
  Map<String, int> getNotificationStats() {
    return {
      'total_sent': 127,
      'order_updates': 45,
      'promotions': 32,
      'price_alerts': 18,
      'restock_alerts': 12,
      'system_updates': 20,
    };
  }

  // Check if any notification type is enabled
  bool get hasAnyNotificationEnabled {
    return _pushNotifications || 
           _emailNotifications || 
           _smsNotifications ||
           _orderUpdates || 
           _promotions || 
           _priceAlerts || 
           _restockAlerts || 
           _systemUpdates;
  }

  // Get enabled notification methods count
  int get enabledNotificationMethodsCount {
    int count = 0;
    if (_pushNotifications) count++;
    if (_emailNotifications) count++;
    if (_smsNotifications) count++;
    return count;
  }

  // Get enabled notification types count
  int get enabledNotificationTypesCount {
    int count = 0;
    if (_orderUpdates) count++;
    if (_promotions) count++;
    if (_priceAlerts) count++;
    if (_restockAlerts) count++;
    if (_systemUpdates) count++;
    return count;
  }
}