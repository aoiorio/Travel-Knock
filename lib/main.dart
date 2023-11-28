import 'package:flutter/material.dart';

// libraries import
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// screens import
import 'package:travelknock/screens/login/login.dart';
import 'package:travelknock/screens/tabs.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://pmmgjywnzshfclavyeix.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBtbWdqeXduenNoZmNsYXZ5ZWl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTY2NzQ5NzEsImV4cCI6MjAxMjI1MDk3MX0.iGqgR-1EAXecyi6sF9eXzfFJRqBqnN0F9hmpjDA43HM',
    authFlowType: AuthFlowType.pkce,
  );

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
  //許可する向きを指定する。
    DeviceOrientation.portraitUp, //上向きを許可
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the travel of your application.
  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print('PlansScreen');
            // DONE replace the screen to PlansScreen
            return const TabsScreen(
              initialPageIndex: 0,
            );
          }
          // If user was login as a guest, I want the user can see the PlansScreen. How do I implement it?
          print('LoginScreen');
          return const LoginScreen();
        },
      ),
    );
  }
}
