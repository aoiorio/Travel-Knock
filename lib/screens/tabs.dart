import 'package:flutter/material.dart';

// library import
import 'package:supabase_flutter/supabase_flutter.dart';

// screens import
import 'package:travelknock/screens/login/login.dart';
import 'package:travelknock/screens/login/sign_in_with_apple.dart';
import 'package:travelknock/screens/login/sign_in_with_google.dart';
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

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialPageIndex;
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: width * 0.38,
                        height: height * 0.08,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side:
                                const BorderSide(color: Colors.black, width: 2),
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
                            side:
                                const BorderSide(color: Colors.black, width: 2),
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
          : _pages[_currentPageIndex],
    );
  }
}
