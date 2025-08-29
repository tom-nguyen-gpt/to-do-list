import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../providers/task_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _dailyReminder = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    await NotificationService.instance.init();
    
    setState(() {
      _notificationsEnabled = NotificationService.instance.areNotificationsEnabled;
      _dailyReminder = NotificationService.instance.isDailyReminderEnabled;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text(
                    'Receive notifications for task reminders and updates',
                  ),
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    await NotificationService.instance.setNotificationsEnabled(value);
                    
                    // If notifications are enabled, reschedule task notifications
                    if (value) {
                      // Get the task provider and reschedule all task notifications
                      final taskProvider = Provider.of<TaskProvider>(
                        context, listen: false);
                      if (taskProvider.userId != null) {
                        taskProvider.rescheduleAllTaskNotifications();
                      }
                    }
                    
                    setState(() {
                      _notificationsEnabled = value;
                      // If notifications are disabled, disable daily reminder too
                      if (!value) {
                        _dailyReminder = false;
                      }
                    });
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Daily Task Reminder'),
                  subtitle: const Text(
                    'Get a daily reminder of your pending tasks at 9:00 AM',
                  ),
                  value: _dailyReminder && _notificationsEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) async {
                          await NotificationService.instance.setDailyReminderEnabled(value);
                          setState(() {
                            _dailyReminder = value;
                          });
                        }
                      : null,
                ),
                const Divider(),
                ListTile(
                  title: const Text('Task Due Date Reminders'),
                  subtitle: const Text(
                    'You will receive a reminder 1 hour before a task is due',
                  ),
                  trailing: Icon(
                    Icons.info_outline,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Note: Make sure your device settings allow notifications from this app for all notification features to work properly.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                if (!_notificationsEnabled)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Card(
                      color: Color(0xFFFFECB3),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Notifications are currently disabled. You will not receive any task reminders or updates.',
                          style: TextStyle(color: Color(0xFF8A6D3B)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}