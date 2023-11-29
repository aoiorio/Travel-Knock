import 'package:flutter/material.dart';

// libraries import
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travelknock/preferences/preferences_manager.dart';

// screens import
import 'package:travelknock/screens/login/login.dart';
import 'package:travelknock/screens/tabs.dart';

void main() async {
  // envを召喚
  await dotenv.load(fileName: '.env');

  final String anonKey = dotenv.env['SUPABASE_ANON'] ?? ''; // Anon keyを.envから取得
  final String projectUrl = dotenv.env['SUPABASE_URL'] ?? ''; // URLを.envから取得

  await Supabase.initialize(
    url: projectUrl,
    anonKey: anonKey,
    authFlowType: AuthFlowType.pkce,
  );

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    //許可する向きを指定する。
    DeviceOrientation.portraitUp, //上向きを許可
  ]);
  // preferences の初期化
  await PreferencesManager().set(await SharedPreferences.getInstance());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLogin = false;
  // This widget is the travel of your application.
  void getIsLogin() async {
    bool isLogin = await PreferencesManager().isLogin;
    setState(() {
      _isLogin = isLogin;
    });
  }

  @override
  void initState() {
    super.initState();
    getIsLogin();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _isLogin
            ? const TabsScreen(initialPageIndex: 0)
            : const LoginScreen()
        // StreamBuilder(
        //   stream: supabase.auth.onAuthStateChange,
        //   builder: (context, snapshot) {
        //     if (snapshot.hasData) {
        //       print('PlansScreen');
        //       // DONE replace the screen to PlansScreen
        //       return const TabsScreen(
        //         initialPageIndex: 0,
        //       );
        //     }
        //     // If user was login as a guest, I want the user can see the PlansScreen. How do I implement it?
        //     print('LoginScreen');
        //     return const LoginScreen();
        //   },
        // ),
        );
  }
}
