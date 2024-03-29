import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_notify_app/api/firebase_api.dart';
import 'package:my_notify_app/firebase_options.dart';
import 'package:my_notify_app/page/home_screen.dart';

import 'page/notification_screen.dart';

final navigetorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FireBaseApi().initNotifications();

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: navigetorKey,
      home: const MyWidget(),
      routes: {
        NotificationScreen.routeName: (context) => const NotificationScreen(),
      },
    );
  }
}

class HomeScreen {
  const HomeScreen();
}
