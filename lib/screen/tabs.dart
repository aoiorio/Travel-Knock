import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/screen/plans/plans.dart';
import 'package:travelknock/screen/profile.dart';

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
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('You should to sign in!')],
              ),
            )
          : _pages[_currentPageIndex],
    );
  }
}
