import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class LoginPageScreen extends StatelessWidget {
  const LoginPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  height: 360,
                  color: const Color(0xff4B4B5A),
                ),
              ),
              // ロゴを表示
              Container(
                padding: const EdgeInsets.only(top: 150),
                child: Center(
                  child: SizedBox(
                    width: 300,
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
                height: 75,
                width: 300,
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
                height: 75,
                width: 270,
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
          SizedBox(
            width: 300,
            height: 70,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              onPressed: () {},
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
          SizedBox(
            width: 300,
            height: 70,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
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
