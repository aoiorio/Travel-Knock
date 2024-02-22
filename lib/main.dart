import 'package:flutter/material.dart';

// libraries import
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travelknock/preferences/preferences_manager.dart';
import 'package:travelknock/screens/introduction/introduction.dart';

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
  // preferences の初期化
  await PreferencesManager().set(await SharedPreferences.getInstance());
  await IntroductionManager().set(await SharedPreferences.getInstance());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLogin = false;
  bool _isIntroduced = false;
  // This widget is the travel of your application.
  void getIsLogin() async {
    bool isLogin = await PreferencesManager().isLogin;
    setState(() {
      _isLogin = isLogin;
    });
  }

  void getIsIntroduced() async {
    bool isIntroduced = await IntroductionManager().isIntroduced;
    if (!mounted) return;
    setState(() {
      _isIntroduced = isIntroduced;
    });
  }

  @override
  void initState() {
    super.initState();
    getIsLogin();
    getIsIntroduced();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      //許可する向きを指定する。
      DeviceOrientation.portraitUp, //上向きを許可
    ]);
    return MaterialApp(
        theme: ThemeData(useMaterial3: false),
        debugShowCheckedModeBanner: false,
        // shared preferencesを使って取得したisLoginがtrueだったらTabsScreenが初期画面になる
        // if the user checked introduction screen, next time it'll never show to them
        home: _isLogin
            ? _isIntroduced
                ? const TabsScreen(initialPageIndex: 0)
                : const IntroductionScreens()
            : const LoginScreen());

    // for debug
    // _isLogin ? const IntroductionScreens() : const LoginScreen());
  }
}
