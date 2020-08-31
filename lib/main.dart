import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import './providers/tasks_provider.dart';
import './providers/user.dart';
import './screens/settings_screen.dart';
import './screens/task_detail_screen.dart';
import './screens/task_edit_screen.dart';
import './screens/tasks_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

NotificationAppLaunchDetails notificationAppLaunchDetails;

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {},
              child: Text("Okay"),
            ),
          ],
        );
      });
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  });
  runApp(
    MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final MaterialColor mycolor = const MaterialColor(0xFF88B9B6, const {
    50: const Color(0xFFAFD0CE),
    100: const Color(0xFF9FC6C4),
    200: const Color(0xFF8FBDBA),
    300: const Color(0xFF5EA19C),
    400: const Color(0xFF55918D),
    500: const Color(0xFF42706D),
    600: const Color(0xFF39605E),
    700: const Color(0xFF2F504E),
    800: const Color(0xFF26403E),
    900: const Color(0xFF1C302F)
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => TasksProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Todo App',
        theme: ThemeData(
          textTheme: ThemeData.light().textTheme.copyWith(
                title: TextStyle(
                  fontFamily: 'Galada',
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Color.fromRGBO(57, 96, 94, 1),
                ),
              ),
          primaryColor: Color.fromRGBO(136, 185, 182, 1),
          primarySwatch: mycolor,
          accentColor: Color.fromRGBO(57, 96, 94, 1),
        ),
        home: FutureBuilder(
            future: FirebaseAuth.instance.currentUser(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return SplashScreen();
              if (snapshot.hasData) {
                return Builder(
                  builder: (ctx) {
                    return FutureBuilder(
                        future: Firestore.instance
                            .collection('users')
                            .document(snapshot.data.uid)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SplashScreen();
                          }
                          Provider.of<UserProvider>(context, listen: false)
                              .setUser(
                            snapshot.data.uid,
                            userSnapshot.data['email'],
                            userSnapshot.data['username'],
                          );

                          return TasksScreen();
                        });
                  },
                );
              }
              return AuthScreen();
            }),
        routes: {
          TasksScreen.routeName: (ctx) => TasksScreen(),
          SplashScreen.routeName: (ctx) => SplashScreen(),
          AuthScreen.routeName: (ctx) => AuthScreen(),
          TaskEditScreen.routeName: (ctx) => TaskEditScreen(),
          TaskDetailScreen.routeName: (ctx) => TaskDetailScreen(),
          SettingsScreen.routeName: (ctx) => SettingsScreen(),
        },
      ),
    );
  }
}
