import 'package:flutter/material.dart';

// library import
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

// screens import
import 'package:travelknock/screens/login/login.dart';
import 'package:travelknock/screens/plans/plans.dart';
import 'package:travelknock/screens/profile/own_profile.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key, required this.initialPageIndex});

  final int initialPageIndex;

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  var _currentPageIndex = 0;
  // final List _userData = [];

  final _pages = <Widget>[
    const PlansScreen(),
    const ProfileScreen(),
  ];

  List<IconData> listOfIcons = [
    Icons.door_back_door,
    Icons.cloud,
  ];

  List<IconData> selectedIcons = [
    Icons.door_back_door_outlined,
    Icons.cloud_outlined
  ];

  // ランダムなuserNameを作成(usernameはuniqueなため)
  String generateUserName() {
    const length = 8;
    const String charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz';
    final Random random = Random.secure();
    final String randomStr =
        List.generate(length, (_) => charset[random.nextInt(charset.length)])
            .join();
    debugPrint(randomStr);
    return randomStr;
  }

  // appleでサインインした時や、user情報を設定していなかったときに強制設定する関数
  void setUserData() async {
    final supabase = Supabase.instance.client;

    if (supabase.auth.currentUser == null) {
      return;
    }
    final userId = supabase.auth.currentUser!.id;
    try {
      final userData =
          await supabase.from('profiles').select('*').eq('id', userId);
      if (userData[0]['avatar_url'] == null) {
        await supabase.from('profiles').update({
          'avatar_url':
              'https://pmmgjywnzshfclavyeix.supabase.co/storage/v1/object/public/posts/30fe397b-74c1-4c5c-b037-a586917b3b42/grey-icon.jpg'
        }).eq('id', userId);
      }
      if (userData[0]['username'] == null) {
        await supabase
            .from('profiles')
            .update({'username': generateUserName()}).eq('id', userId);
      }
      if (userData[0]['places'] == null) {
        await supabase.from('profiles').update({
          'places': ["Travel island"]
        }).eq('id', userId);
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialPageIndex;
    setUserData();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final supabase = Supabase.instance.client;
    return Scaffold(
      // transparent margin background.
      extendBody: true,
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
            right: width >= 500 ? width * 0.5 : width * 0.25,
            bottom: 90), // 120 , 90
        // width: 91,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xff4B4B5A),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: ListView.builder(
          itemCount: listOfIcons.length,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: width * 0.04), // 10
          itemExtent: width >= 500 ? width * 0.2 : width * 0.31, // 120
          itemBuilder: (context, index) => InkWell(
            onTap: () {
              setState(
                () {
                  _currentPageIndex = index;
                },
              );
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.fastLinearToSlowEaseIn,
                  margin: EdgeInsets.only(
                    bottom: index == _currentPageIndex ? 10 : 0,
                    left: 70,
                    right: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(10),
                    ),
                  ),
                ),
                Icon(
                  index == _currentPageIndex
                      ? listOfIcons[index]
                      : selectedIcons[index],
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),

      // if the user is anonymous and he/she visited ProfileScreen;
      body: supabase.auth.currentUser == null && _currentPageIndex == 1
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: width >= 1000 ? width * 0.5 : width,
                    // DONE change illustration
                    child: Image.asset('assets/images/no-login.PNG'),
                  ),
                  const Text(
                    'You should sign in!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(
                    width: 300,
                    child: Text(
                      "You can't use other features of Travel Knock without sign in.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xff4B4B5A)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: width * 0.38,
                        height: height * 0.08,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xff4B4B5A), width: 2),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                              builder: (context) {
                                return const LoginScreen();
                              },
                            ), (route) => false);
                          },
                          child: SizedBox(
                            width: 40,
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
                            side: const BorderSide(
                                color: Color(0xff4B4B5A), width: 2),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                              builder: (context) {
                                return const LoginScreen();
                              },
                            ), (route) => false);
                          },
                          child: SizedBox(
                            width: 35,
                            child: Image.asset("assets/images/google-logo.png"),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: width >= 1000 ? 50 : 20)
                ],
              ),
            )
            // : const IntroductionScreens()
          : _pages[_currentPageIndex],
    );
  }
}
