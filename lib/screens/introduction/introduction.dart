import 'package:flutter/material.dart';

// libraries import
import 'package:flutter/foundation.dart';

// components
import 'package:travelknock/preferences/preferences_manager.dart';

// screens
import 'package:travelknock/screens/tabs.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroductionScreens extends StatefulWidget {
  const IntroductionScreens({super.key});

  @override
  State<IntroductionScreens> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreens> {

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyAlignment: Alignment.center,
    );
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Enjoy your \n infinity journey with \n Travel Knock!",
          body: "Welcome to Travel Knock.",
          image: Container(
            margin: const EdgeInsets.only(top: 100),
            child: Image.asset(
              "assets/images/no-your-knock.PNG",
              height: 600,
            ),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Explore the Features",
          body: "Our app has many great features.",
          image: Center(
            child: Image.asset(
              "assets/images/no-posts.PNG",
            ),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Tap cloud icon to set your icon",
          body: "",
        ),
      ],
      // Actions to perform when the introduction screens are completed
      onDone: () async {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) {
            return const TabsScreen(
              initialPageIndex: 0,
            );
          },
        ), (route) => false);
        // sharedPreferencesにisLoginというkeyに保存する
        await IntroductionManager().setIsIntroduced(isIntroduced: true);
      },
      done: const Text(
        'Done',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xff4B4B5A),
          fontSize: 20,
        ),
      ),
      showSkipButton: true,
      showBackButton: false,
      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back),
      skip: const Text(
        'Skip',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xff4B4B5A),
          fontSize: 20,
        ),
      ),
      next: const Icon(
        Icons.arrow_forward,
        color: Color(0xff4B4B5A),
        size: 30,
      ),
      skipOrBackFlex: 0,
      nextFlex: 0,
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(15.0, 15.0),
        color: Color(0xffD9D9D9),
        activeSize: Size(22.0, 10.0),
        activeColor: Color(0xff4B4B5A),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
