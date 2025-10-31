import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('Notification (background) tap: ${notificationResponse.payload}');
}

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); 

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
         print('Notification (foreground/bg) tap: ${notificationResponse.payload}');
         // TODO: Tambahkan navigasi jika perlu
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

     await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel); 
        
     await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission(); 
  }

  static void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
     print('Received local notification (iOS old): $payload');
  }

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'gymbros_channel_id', 
    'Gymbros Notifications', 
    description: 'Notifications for workout reminders and streaks',
    importance: Importance.max,
    playSound: true,
  );

  Future<void> showNotification(String title, String body, {String? payload}) async {
     print("[NotificationService] showNotification called."); 
     
     const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'gymbros_channel_id', 
      'Gymbros Notifications', 
      channelDescription: 'Notifications for workout reminders and streaks',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await flutterLocalNotificationsPlugin.show(
      0, 
      title,
      body,
      platformChannelSpecifics,
      payload: payload ?? 'default_payload',
    );
     print("[NotificationService] showNotification executed."); 
  }

}

