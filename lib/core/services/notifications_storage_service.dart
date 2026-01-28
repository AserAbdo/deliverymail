import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Notification Model for local storage
/// موديل الإشعار للتخزين المحلي
class StoredNotification {
  final String id;
  final String title;
  final String message;
  final String? orderId;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'order_success', 'general', etc.

  StoredNotification({
    required this.id,
    required this.title,
    required this.message,
    this.orderId,
    required this.timestamp,
    this.isRead = false,
    this.type = 'general',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'orderId': orderId,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'type': type,
  };

  factory StoredNotification.fromJson(Map<String, dynamic> json) {
    return StoredNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      orderId: json['orderId'],
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      isRead: json['isRead'] ?? false,
      type: json['type'] ?? 'general',
    );
  }
}

/// Notifications Storage Service
/// خدمة تخزين الإشعارات
class NotificationsStorageService {
  static const String _notificationsKey = 'stored_notifications';
  static const int _maxNotifications = 100; // Maximum notifications to store

  /// Save a notification
  /// حفظ إشعار
  static Future<void> saveNotification({
    required String title,
    required String message,
    String? orderId,
    String type = 'general',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getNotifications();

      // Create new notification
      final newNotification = StoredNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        orderId: orderId,
        timestamp: DateTime.now(),
        isRead: false,
        type: type,
      );

      // Add to beginning of list
      notifications.insert(0, newNotification);

      // Keep only last _maxNotifications
      if (notifications.length > _maxNotifications) {
        notifications.removeRange(_maxNotifications, notifications.length);
      }

      // Save to SharedPreferences
      final jsonList = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  /// Get all notifications
  /// جلب جميع الإشعارات
  static Future<List<StoredNotification>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_notificationsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map(
            (json) => StoredNotification.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error loading notifications: $e');
      return [];
    }
  }

  /// Get unread notifications count
  /// جلب عدد الإشعارات غير المقروءة
  static Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  /// Mark notification as read
  /// وضع علامة مقروء على إشعار
  static Future<void> markAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getNotifications();

      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final updated = StoredNotification(
          id: notifications[index].id,
          title: notifications[index].title,
          message: notifications[index].message,
          orderId: notifications[index].orderId,
          timestamp: notifications[index].timestamp,
          isRead: true,
          type: notifications[index].type,
        );
        notifications[index] = updated;

        final jsonList = notifications.map((n) => n.toJson()).toList();
        await prefs.setString(_notificationsKey, jsonEncode(jsonList));
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  /// وضع علامة مقروء على جميع الإشعارات
  static Future<void> markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getNotifications();

      final updatedNotifications = notifications.map((n) {
        return StoredNotification(
          id: n.id,
          title: n.title,
          message: n.message,
          orderId: n.orderId,
          timestamp: n.timestamp,
          isRead: true,
          type: n.type,
        );
      }).toList();

      final jsonList = updatedNotifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  /// Delete a notification
  /// حذف إشعار
  static Future<void> deleteNotification(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getNotifications();

      notifications.removeWhere((n) => n.id == notificationId);

      final jsonList = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  /// Clear all notifications
  /// مسح جميع الإشعارات
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }
}
