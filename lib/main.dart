import 'package:flutter/material.dart';
import 'package:travelknock/screen/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://pmmgjywnzshfclavyeix.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBtbWdqeXduenNoZmNsYXZ5ZWl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTY2NzQ5NzEsImV4cCI6MjAxMjI1MDk3MX0.iGqgR-1EAXecyi6sF9eXzfFJRqBqnN0F9hmpjDA43HM',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the travel of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }
}
