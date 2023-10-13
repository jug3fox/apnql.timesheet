import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:apnql_timesheet/main.dart';
import 'package:apnql_timesheet/model/general/date.dart';

import '../timesheet/list.dart';


void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  print("bg reponse: ${response.actionId}");

  if (notifications.onClick != null && response.id != null) {
    notifications.onClick!(response.id!);
  }
}

class NotificationService {
  NotificationService(); //0.018933 m
  bool _initialized = false;

  final _localNotifications = FlutterLocalNotificationsPlugin();


  Future<void> initializePlatformNotifications() async {

    _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/main_icon');

    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(
        defaultActionName: 'Open notification');

    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux);

    await _localNotifications.initialize(
        initializationSettings,
        //onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse
    );


    _initialized = true;
    return;
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print('idd $id');
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) {
    print("reponse: ${response.id}");
    if (onClick != null && response.id != null) {
      onClick!(response.id!);
    }
  }

  Future<NotificationDetails> _notificationDetails({
    List<AndroidNotificationAction>? actions,
    String? text,
  }) async {

    AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      '101',
      'timesheet_details',
      groupKey: 'com.apnql.flutter_push_notifications',
      channelDescription: 'Details for timesheet',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      actions: actions,
      //colorized: true,
      category: AndroidNotificationCategory.reminder,
      //ongoing: true,
      styleInformation: text == null ? null : BigTextStyleInformation(text),

      autoCancel: false,
      icon: '@mipmap/main_icon',
      ticker: 'ticker',
      color: Colors.red,
    );

    DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
      threadIdentifier: "thread1",
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosNotificationDetails
    );

    return platformChannelSpecifics;
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    List<AndroidNotificationAction>? actions,
    String payload = "payload",
    required Function(int id) onClick,
  }) async {
    this.onClick = onClick;
    if (!_initialized) await initializePlatformNotifications();
    final platformChannelSpecifics = await _notificationDetails(actions: actions);

    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }


  Function(int id)? onClick;
  Future<void> showTimesheetNotification({
    required TimesheetWeek prevWeek,
    List<AndroidNotificationAction>? actions,
    required Function(int id) onClick,
  }) async {
    this.onClick = onClick;
    if (!_initialized) await initializePlatformNotifications();
    final bool sameMonth = prevWeek.week.start.month == prevWeek.week.end.month;
    final bool sameYear = prevWeek.week.start.year == prevWeek.week.end.year;
    final String text = "Votre feuille de temps pour la semaine dernière "
        "(${DateFormat("d${sameMonth ? "" : " MMMM"}${sameYear ? "" : " YYYY"}", "fr_CA").format(prevWeek.week.start)} au "
        "${DateFormat("d MMMM${sameYear ? "" : " YYYY"}", "fr_CA").format(prevWeek.week.end)}) n'a pas été envoyé";
    final platformChannelSpecifics = await _notificationDetails(actions: actions, text: text);

    await _localNotifications.show(
      400,
      "ATTENTION",
      "Feuille de temps non soumise",
      platformChannelSpecifics,
      payload: "payload",
    );
  }

  Future<void> get cancelTimesheetNotification async {
    await _localNotifications.cancel(400);
    return;
  }
}