// import 'dart:js_interop';

import 'package:flutter/material.dart';

import 'package:travelknock/screen/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/screen/setting_profile.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://pmmgjywnzshfclavyeix.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBtbWdqeXduenNoZmNsYXZ5ZWl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTY2NzQ5NzEsImV4cCI6MjAxMjI1MDk3MX0.iGqgR-1EAXecyi6sF9eXzfFJRqBqnN0F9hmpjDA43HM',
    authFlowType: AuthFlowType.pkce,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the travel of your application.
  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    Future<dynamic> isSetProfile() async {
      final userIsSettingProfile = await supabase
          .from('profiles')
          .select()
          .eq('id', supabase.auth.currentUser!.id)
          .single();
      final isSet = userIsSettingProfile['is_setting_profile'] == false;
      return isSet;
    }

    return MaterialApp(
      home: StreamBuilder(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print('PlansScreen');
            // TODO replace the screen to PlansScreen
            return const SettingProfileScreen();
          }
          print('LoginScreen');
          return const LoginScreen();
        },
      ),
    );
  }
}
