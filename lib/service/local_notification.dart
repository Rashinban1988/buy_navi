/*
* Copyright 2023 otomamay. All Rights Reserved.
*/

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  static final LocalNotification _singleton = LocalNotification._internal();

  LocalNotification._internal();

  factory LocalNotification() {
    return _singleton;
  }

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  // ローカル通知初期化
  Future initLocalNotification() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPluginInitialize();
  }

  // flutterLocalNotificationsPlugin Initialize
  flutterLocalNotificationsPluginInitialize() {
    _flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestSoundPermission: true,
          requestBadgePermission: true,
        )));
  }

  // Foreground messages
  void foregroundMessageListener() {
    
    // プッシュ通知登録
    NotificationDetails notificationDetails = const NotificationDetails(
      // android用detail
      android: AndroidNotificationDetails(
        '1',
        'testchannel',
        playSound: true,
        color: Colors.red,
      ),
    );

    // 即時通知
    _flutterLocalNotificationsPlugin.show(
      1,
      'testmessage',
      'testbodymessage',
      notificationDetails,
    );
  }

  // 通知を送信する関数
  Future<void> showNotificationTest() async {
    // クロスプラットフォームへのローカル通知用プラグイン
    FlutterLocalNotificationsPlugin notifications =
        FlutterLocalNotificationsPlugin();
    // android初期化
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    // iosやmacなどDarwinベースのOS初期化
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    // 各プラットフォームの初期化
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    // プラグイン初期化
    await notifications.initialize(initializationSettings);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '1',
      'Notification when nearby a shop',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      icon: "@mipmap/ic_launcher",
    );

    // 各プラットフォームでの通知内容
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(iOS: DarwinNotificationDetails());
    // 即時通知
    await notifications.show(
        0, '買い物忘れはないですか？', '初回起動時テスト', platformChannelSpecifics, payload: '/shoplist',);
  }

  // 通知を送信する関数
  Future<void> showNotification() async {
    // クロスプラットフォームへのローカル通知用プラグイン
    FlutterLocalNotificationsPlugin notifications =
        FlutterLocalNotificationsPlugin();
    // android初期化
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    // iosやmacなどDarwinベースのOS初期化
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    // 各プラットフォームの初期化
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    // プラグイン初期化
    await notifications.initialize(initializationSettings);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '1',
      'Notification when nearby a shop',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      icon: "@mipmap/ic_launcher",
    );

    // 各プラットフォームでの通知内容
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(iOS: DarwinNotificationDetails());
    // 即時通知
    await notifications.show(
        0, '買い物忘れはないですか？', '登録店舗から1km以内に入っています', platformChannelSpecifics);
  }
}

final localNotification = LocalNotification();
