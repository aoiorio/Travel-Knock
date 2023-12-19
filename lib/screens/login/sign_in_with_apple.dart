import 'package:flutter/material.dart';

// libraries import
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// preferences import
import 'package:travelknock/preferences/preferences_manager.dart';

class SignInWithAppleClass {
  final supabase = Supabase.instance.client;
  String _generateRandomString() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  /// Performs Apple sign in on iOS or macOS
  Future<AuthResponse> signInWithApple() async {
    try {
      await PreferencesManager().setIsLogin(isLogin: true);

      final rawNonce = _generateRandomString();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        await PreferencesManager().setIsLogin(isLogin: false);
        throw const AuthException(
            'Could not find ID Token from generated credential.');
      }

      return supabase.auth.signInWithIdToken(
        provider: Provider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
    } on Exception {
      debugPrint("something went wrong with Apple sign in or user pressed cancel button");
      await PreferencesManager().setIsLogin(isLogin: false);
    }
    return AuthResponse();
  }
}
