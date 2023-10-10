import 'dart:io';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'dart:math';

import 'package:travelknock/screen/setting_profile.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final supabase = Supabase.instance.client;
  bool _isLogin = false;
  int authcount = 0;

  @override
  void initState() {
    _setupAuthListener();
    super.initState();
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        authcount++;
        print(authcount);
        _isLogin = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SettingProfileScreen(),
          ),
        );
      }
    });
  }

  /// Function to generate a random 16 character string.
  String _generateRandomString() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  Future<AuthResponse> signInWithGoogle() async {
    // Just a random string
    final rawNonce = _generateRandomString();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    ///
    /// Client ID that you registered with Google Cloud.
    /// You will have two different values for iOS and Android.
    final clientId = Platform.isIOS
        ? '399247997641-5occm8fenmli33df9rknak6akf5d720q.apps.googleusercontent.com'
        : '399247997641-qbscm6uru2ik82tbhe30ison3rmimdve.apps.googleusercontent.com';

    /// reverse DNS form of the client ID + `:/` is set as the redirect URL
    final redirectUrl = '${clientId.split('.').reversed.join('.')}:/';

    /// Fixed value for google login
    const discoveryUrl =
        'https://accounts.google.com/.well-known/openid-configuration';

    final appAuth = FlutterAppAuth();

    // authorize the user by opening the concent page
    final result = await appAuth.authorize(
      AuthorizationRequest(
        clientId,
        redirectUrl,
        discoveryUrl: discoveryUrl,
        nonce: hashedNonce,
        scopes: [
          'openid',
          'email',
        ],
      ),
    );

    if (result == null) {
      throw 'No result';
    }

    // Request the access and id token to google
    final tokenResult = await appAuth.token(
      TokenRequest(
        clientId,
        redirectUrl,
        authorizationCode: result.authorizationCode,
        discoveryUrl: discoveryUrl,
        codeVerifier: result.codeVerifier,
        nonce: result.nonce,
        scopes: [
          'openid',
          'email',
        ],
      ),
    );

    final idToken = tokenResult?.idToken;

    if (idToken == null) {
      throw 'No idToken';
    }

    return supabase.auth.signInWithIdToken(
      provider: Provider.google,
      idToken: idToken,
      nonce: rawNonce,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLogin
        ? const SettingProfileScreen()
        : Scaffold(
            backgroundColor: const Color(0xffC7C7C7),
            body: Column(
              children: [
                // 変な形の上にロゴを乗っける
                Stack(
                  children: [
                    // 変な形を作ってくれるpackage
                    ClipPath(
                      clipper: WaveClipperTwo(),
                      child: Container(
                        height: 340,
                        color: const Color(0xff4B4B5A),
                      ),
                    ),
                    // ロゴを表示
                    Container(
                      padding: const EdgeInsets.only(top: 150),
                      child: Center(
                        child: SizedBox(
                          width: 340,
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
                const SizedBox(
                  height: 30,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 70,
                      width: 270,
                      child: DecoratedBox(
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
                const SizedBox(
                  height: 50,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 70,
                      width: 250,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xffA7A7A7),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),

                // Sign in with google button
                SizedBox(
                  width: 300,
                  height: 60,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    // TODO add feature that login with Google
                    onPressed: signInWithGoogle,
                    icon: SizedBox(
                      width: 30,
                      child: Container(
                          padding: const EdgeInsets.only(right: 4),
                          child: Image.asset('assets/images/google-logo.png')),
                    ),
                    label: const Text(
                      'Sign In With Google',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),

                // Join as a guest button
                SizedBox(
                  width: 300,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    // TODO Add feature that transition to PlansScreen.
                    onPressed: () {},
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
              ],
            ),
          );
  }
}
