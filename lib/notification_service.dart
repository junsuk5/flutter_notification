import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class NotificationService {
  Future<void> initializeTimeZone() async {
    tz.initializeTimeZones();
    final timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> initializeNotification() async {
    // Android 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        // TODO: iOS 알림 받았을 때 처리
      },
    );

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  String _alarmId(int medicineId, String alarmTime) {
    return medicineId.toString() + alarmTime.replaceAll(':', '');
  }

  Future<bool> showNotification(int id, String title, String body,
      {String? payload}) async {

    if (await permissionNotification) {
      flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        _notificationDetails(),
        payload: payload,
      );
      return true;
    } else {
      // 안내
      return false;
    }
  }

  Future<bool> addScheduledNotification({
    required int id,
    required String alarmTimeStr,
    required String title, // HH:mm 약 먹을 시간이예요!
    required String body, // {약이름} 복약했다고 알려주세요!
  }) async {
    if (!await permissionNotification) {
      // show native setting page
      return false;
    }

    /// exception
    final now = tz.TZDateTime.now(tz.local);
    final alarmTime = DateFormat('HH:mm').parse(alarmTimeStr);
    final day = (alarmTime.hour < now.hour ||
        alarmTime.hour == now.hour && alarmTime.minute <= now.minute)
        ? now.day + 1
        : now.day;

    /// id
    String alarmTimeId = _alarmId(id, alarmTimeStr);

    /// add schedule notification
    final details = _notificationDetails();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      int.parse(alarmTimeId), // unique
      title,
      body,
      tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        day,
        alarmTime.hour,
        alarmTime.minute,
      ),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: alarmTimeId,
    );
    return true;
  }

  NotificationDetails _notificationDetails() {
    const android = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.max,
      // sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    const DarwinNotificationDetails iosNotificationDetails =
    DarwinNotificationDetails(
      categoryIdentifier: 'channel_name',
    );

    return const NotificationDetails(
      android: android,
      iOS: iosNotificationDetails,
    );
  }

  Future<bool> get permissionNotification async {
    if (Platform.isAndroid) {
      return await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission() ??
          false;
    } else if (Platform.isIOS) {
      return await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    } else {
      return false;
    }
  }
}