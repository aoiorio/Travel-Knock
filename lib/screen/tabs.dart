import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/screen/login.dart';
import 'package:travelknock/screen/plans/plans.dart';
import 'package:travelknock/screen/own_profile.dart';

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
    final supabase = Supabase.instance.client;
    return Scaffold(
      // transparent margin background.
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(right: 120, bottom: 90),
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
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemExtent: 120,
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
                  Image.asset('assets/images/no-knocked.PNG'),
                  const Text(
                    'You should sign in!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                      // DONE add feature that login with Google
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) {
                            return const LoginScreen();
                          },
                        ));
                      },
                      icon: SizedBox(
                        width: 30,
                        child: Container(
                            padding: const EdgeInsets.only(right: 4),
                            child:
                                Image.asset('assets/images/google-logo.png')),
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
                ],
              ),
            )
          : _pages[_currentPageIndex],
    );
  }
}
