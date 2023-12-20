import 'package:flutter/material.dart';

// libraries import
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// preferences import
import 'package:travelknock/preferences/preferences_manager.dart';

class SignInWithGoogleClass {
  final supabase = Supabase.instance.client;

  String _generateRandomString() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  Future<AuthResponse> signInWithGoogle() async {
    await PreferencesManager().setIsLogin(isLogin: true);
    try {
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

      const appAuth = FlutterAppAuth();

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
        await PreferencesManager().setIsLogin(isLogin: false);
        throw 'No idToken';
      }

      return supabase.auth.signInWithIdToken(
        provider: Provider.google,
        idToken: idToken,
        nonce: rawNonce,
      );
    } on Exception {
      debugPrint("Something went wrong with Google Sign in or user pressed cancel button");
      await PreferencesManager().setIsLogin(isLogin: false);
    }

    // Just a random string
    return AuthResponse();
  }
}
