import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/task.dart' as model;

/// Mock implementation of notification service for testing UI
/// This implementation doesn't actually schedule notifications,
/// but it maintains the preferences and simulates the behavior
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;
  
  bool _isInitialized = false;
  bool _areNotificationsEnabled = true;
  bool _isDailyReminderEnabled = false;
  
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _dailyReminderEnabledKey = 'daily_reminder_enabled';
  
  NotificationService._();
  
  // For debugging
  void _log(String message) {
    debugPrint('NotificationService: $message');
  }
  
  Future<void> init() async {
    if (_isInitialized) return;
    
    // Load notification preferences
    await _loadNotificationPreferences();
    
    _log('Notification service initialized');
    _isInitialized = true;
  }
  
  Future<void> _loadNotificationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _areNotificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
      _isDailyReminderEnabled = prefs.getBool(_dailyReminderEnabledKey) ?? false;
      _log('Loaded preferences: notifications=${_areNotificationsEnabled}, dailyReminder=${_isDailyReminderEnabled}');
    } catch (e) {
      _log('Error loading notification preferences: $e');
    }
  }
  
  Future<void> _saveNotificationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, _areNotificationsEnabled);
      await prefs.setBool(_dailyReminderEnabledKey, _isDailyReminderEnabled);
      _log('Saved preferences: notifications=${_areNotificationsEnabled}, dailyReminder=${_isDailyReminderEnabled}');
    } catch (e) {
      _log('Error saving notification preferences: $e');
    }
  }
  
  // Simulates scheduling a task reminder
  Future<void> scheduleTaskReminder(model.Task task) async {
    if (!_isInitialized || !_areNotificationsEnabled || task.dueDate == null) return;
    
    final taskId = task.id;
    final dueDate = task.dueDate!;
    
    // Calculate notification time (1 hour before due date)
    final notificationTime = dueDate.subtract(const Duration(hours: 1));
    
    // Don't schedule if the time has already passed
    if (notificationTime.isBefore(DateTime.now())) return;
    
    _log('Scheduled task reminder for: ${task.title} due ${_formatReminderTime(dueDate)}');
  }
  
  // Simulates cancelling a task reminder
  Future<void> cancelTaskReminder(String taskId) async {
    if (!_isInitialized) return;
    _log('Cancelled task reminder for task ID: $taskId');
  }
  
  // Simulates cancelling all task reminders
  Future<void> cancelTaskReminders() async {
    if (!_isInitialized) return;
    _log('Cancelled all task reminders');
  }
  
  // Simulates scheduling a daily reminder
  Future<void> scheduleDailyReminder() async {
    if (!_isInitialized || !_areNotificationsEnabled || !_isDailyReminderEnabled) return;
    
    // Schedule for 9:00 AM every day
    final now = DateTime.now();
    final scheduledDate = DateTime(
      now.year, 
      now.month, 
      now.day, 
      9, 0, // 9:00 AM
    );
    
    // If 9:00 AM today has already passed, schedule for tomorrow
    var scheduledDateTime = scheduledDate;
    if (scheduledDate.isBefore(now)) {
      scheduledDateTime = scheduledDate.add(const Duration(days: 1));
    }
    
    _log('Scheduled daily reminder for: ${scheduledDateTime.toString()}');
  }
  
  // Simulates cancelling the daily reminder
  Future<void> cancelDailyReminder() async {
    if (!_isInitialized) return;
    _log('Cancelled daily reminder');
  }
  
  // Simulates showing an instant notification
  Future<void> showInstantNotification(String title, String body) async {
    if (!_isInitialized || !_areNotificationsEnabled) return;
    _log('Showing instant notification: $title - $body');
  }
  
  // Getter and setter for notification preferences
  bool get areNotificationsEnabled => _areNotificationsEnabled;
  
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_areNotificationsEnabled == enabled) return;
    
    _areNotificationsEnabled = enabled;
    await _saveNotificationPreferences();
    
    if (!enabled) {
      // Cancel all notifications if disabled
      _log('Cancelling all notifications');
    } else {
      // Reschedule notifications for tasks
      await rescheduleAllTaskNotifications();
    }
  }
  
  // Method to be called to reschedule all task notifications
  Future<void> rescheduleAllTaskNotifications() async {
    // This should be called by the task provider
    // after toggling notification settings
    if (!_areNotificationsEnabled) return;
    
    // If daily reminder is enabled, reschedule it
    if (_isDailyReminderEnabled) {
      await scheduleDailyReminder();
    }
    
    _log('Rescheduling all task notifications');
  }
  
  bool get isDailyReminderEnabled => _isDailyReminderEnabled;
  
  Future<void> setDailyReminderEnabled(bool enabled) async {
    if (_isDailyReminderEnabled == enabled) return;
    
    _isDailyReminderEnabled = enabled;
    await _saveNotificationPreferences();
    
    if (enabled) {
      await scheduleDailyReminder();
    } else {
      await cancelDailyReminder();
    }
  }
  
  // Helper for formatting time in a user-friendly way
  String _formatReminderTime(DateTime dueDate) {
    final now = DateTime.now();
    
    if (dueDate.day == now.day && 
        dueDate.month == now.month && 
        dueDate.year == now.year) {
      return 'today at ${_formatTime(dueDate)}';
    } else if (dueDate.day == now.day + 1 && 
               dueDate.month == now.month && 
               dueDate.year == now.year) {
      return 'tomorrow at ${_formatTime(dueDate)}';
    } else {
      return 'on ${_formatDate(dueDate)} at ${_formatTime(dueDate)}';
    }
  }
  
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }
  
  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }
}