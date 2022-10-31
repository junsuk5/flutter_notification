import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final notification = NotificationService();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await notification.initializeTimeZone();
  await notification.initializeNotification();

  notification.showNotification(1, 'fcm title', 'fcm body');

  print('Handling a background message ${message.messageId}');
}

void main() async {
  // 라이브러리들 사용중에 이 코드가 먼저 실행되어야 되는 놈들이 좀 있음
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await notification.initializeTimeZone();
  await notification.initializeNotification();


  final token = await FirebaseMessaging.instance.getToken();
  log(token.toString());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  StreamSubscription<RemoteMessage>? subscription;

  @override
  void initState() {
    super.initState();

    // 화면 뜨자마자
    // foreground fcm 수신 처리
    subscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.data['title'];
      final body = message.data['body'];

      log('foreground fcm');

      notification.showNotification(1, title, body);
    });
  }

  @override
  void dispose() {
    // 화면을 나갈 때
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('노티'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final result =
                await notification.showNotification(1, 'title', 'body');

            // notification.addScheduledNotification(
            //   id: 1,
            //   alarmTimeStr: '16:00',
            //   title: 'title',
            //   body: 'body',
            // );

            if (result == false) {
              // 안내
              if (!mounted) {
                return;
              }
              _showMyDialog();
            }
          },
          child: const Text('로컬 노티'),
        ),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
