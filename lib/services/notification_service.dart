import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('NotificationService already initialized');
      return;
    }
    debugPrint('Initializing NotificationService...');

    // Initialize time zones
    tz.initializeTimeZones();
    debugPrint('Time zones initialized');

    // Create notification channel for Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'fraud_alerts',
      'Fraud Alerts',
      description: 'Alerts for potential fraudulent activities',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
      showBadge: true,
    );

    // Initialize settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize settings for iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    // Initialize settings for both platforms
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );

    // Create the notification channel
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _isInitialized = true;
  }

  Future<void> showFraudAlertNotification({
    required String senderName,
    required String amount,
  }) async {
    debugPrint('showFraudAlertNotification called for $senderName (₹$amount)');
    if (!_isInitialized) {
      debugPrint('NotificationService not initialized, initializing...');
      await initialize();
    }

    try {
      // Create a unique notification ID
      final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Create a notification channel for Android 8.0+
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'fraud_alerts',
        'Fraud Alerts',
        description: 'Alerts for potential fraudulent activities',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // Create the notification channel
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Create the notification details
      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: Priority.high,
        ticker: 'ticker',
        styleInformation: const BigTextStyleInformation(''),
        color: const Color(0xFFB71C1C),
        enableVibration: true,
        playSound: true,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        timeoutAfter: 0, // Don't auto-dismiss
        showWhen: true,
        when: DateTime.now().millisecondsSinceEpoch,
        autoCancel: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
        interruptionLevel: InterruptionLevel.active,
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iOSPlatformChannelSpecifics,
      );

      debugPrint('Showing notification for $senderName (₹$amount)');
      await _notifications.show(
        notificationId,
        '⚠️ Potential Fraud Alert',
        'You received ₹$amount from $senderName who is marked as unverified. Be cautious!',
        platformChannelSpecifics,
        payload: 'fraud_alert',
      );

      debugPrint('Notification shown successfully with ID: $notificationId');
    } catch (e, stackTrace) {
      debugPrint('Error showing notification: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
