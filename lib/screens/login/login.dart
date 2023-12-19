import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// libraries import
import 'dart:convert';
import 'dart:math';

import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/preferences/preferences_manager.dart';
import 'package:travelknock/screens/login/sign_in_with_apple.dart';
import 'package:travelknock/screens/login/sign_in_with_google.dart';

// screens import
import 'package:travelknock/screens/profile/setting_profile/setting_profile.dart';
import 'package:travelknock/screens/tabs.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final supabase = Supabase.instance.client;

  void _openPrivacyDocument() async {
    final url = Uri.parse(
        "https://docs.google.com/document/d/1TBH6RF4PiEULNeZQmwnim3EyumKzl7cjii_U-xAWypo/edit?usp=sharing");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not Launch $url';
    }
  }

  void _openTermsOfService() async {
    final url = Uri.parse(
        "https://docs.google.com/document/d/15dFvPLZ6knXfQ4fuo6tFZlgfzupChO0PWkUW75ZMurU/edit?usp=sharing");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not Launch $url';
    }
  }

  @override
  void initState() {
    if (supabase.auth.currentUser != null) {
      return;
    }
    _setupAuthListener();
    super.initState();
  }

  void _setupAuthListener() async {
    try {
      supabase.auth.onAuthStateChange.listen((data) {
        final event = data.event;
        if (event == AuthChangeEvent.signedIn) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const SettingProfileScreen(
                isEdit: false,
              ),
            ),
          );
        }
      });
    } on Exception {
      print('mounted');
    }
  }

  /// Function to generate a random 16 character string.
  String _generateRandomString() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xffC7C7C7),
      body: Column(
        children: [
          // 変な形の上にロゴを乗っける
          Stack(
            alignment: Alignment.center,
            children: [
              // 変な形を作ってくれるpackage
              ClipPath(
                clipper: WaveClipperTwo(),
                child: Container(
                  height: height * 0.4, // 340
                  color: const Color(0xff4B4B5A),
                ),
              ),
              // ロゴを表示
              Container(
                // padding: EdgeInsets.only(top: height * 0.175), // 150 どうするかな〜〜〜！！！
                child: Center(
                  child: SizedBox(
                    width: width >= 1000 ? 500 : width * 0.87, // 340
                    child: Image.asset(
                      'assets/images/Travel-Knock-Logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // 二つの四角い形を生成
          SizedBox(
            height: height * 0.04, // 30
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: height * 0.085, // 70
                width: width * 0.69, // 270
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xffA7A7A7),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: height * 0.07, // 50
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: height * 0.085,
                width: width * 0.64, // 250
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xffA7A7A7),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(top: height * 0.03, bottom: height * 0.02),
            // height: height * 0.04, // 40
            child: const Text(
              "Sign In With ",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xff4B4B5A)),
            ),
          ),

          // Sign in with google button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.38,
                height: height * 0.08,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    SignInWithAppleClass().signInWithApple();
                  },
                  child: SizedBox(
                    width: 44,
                    child: Image.asset("assets/images/apple-logo.png"),
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: width * 0.38,
                height: height * 0.08,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    SignInWithGoogleClass().signInWithGoogle();
                  },
                  child: SizedBox(
                    width: 35,
                    child: Image.asset("assets/images/google-logo.png"),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: height * 0.03,
          ),

          // Join as a guest button
          SizedBox(
            width: width * 0.8,
            height: height * 0.08,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              // DONE Add feature that transition to PlansScreen.
              onPressed: () async {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) {
                      return const TabsScreen(
                        initialPageIndex: 0,
                      );
                    },
                  ),
                );
                // sharedPreferencesにisLoginというkeyに保存する
                await PreferencesManager().setIsLogin(isLogin: true);
              },
              child: const Text(
                'Join As A Guest',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: 'privacy policy ・ ',
                        style: const TextStyle(
                            color: Color.fromARGB(255, 26, 131, 166)),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _openPrivacyDocument();
                          }),
                    TextSpan(
                        text: 'terms of service',
                        style: const TextStyle(
                            color: Color.fromARGB(255, 26, 131, 166)),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _openTermsOfService();
                          }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
