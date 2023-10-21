import 'dart:math';

import 'package:flutter/material.dart';
import 'login.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    void signOut() async {
      await supabase.auth.signOut();

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // 回転しちゃうぞ
          Transform.rotate(
            angle: -1 * pi / 180,
            child: Container(
              padding: const EdgeInsets.only(
                left: 310,
                top: 60,
              ),
              child: SizedBox(
                width: 90,
                height: 90,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff4B4B5A),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        bottomLeft: Radius.circular(20),
                        topRight: Radius.circular(0),
                      ),
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: IconButton(
              onPressed: signOut,
              icon: const Icon(
                Icons.exit_to_app,
                size: 40,
              ),
            ),
          ),

          const Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20, top: 120),
                child: Text(
                  "Let's Knock🚪",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}
