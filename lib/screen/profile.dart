// TODO create profile page
import 'package:flutter/material.dart';
import 'package:travelknock/screen/knock/knocked.dart';
import 'package:travelknock/screen/knock/your_knock.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Widget> pages = [];
  int _currentPageIndex = 0;
  final List<String> _pageName = ['Knocked', 'Your Knock'];

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
    pages = [
      const KnockedScreen(),
      const YourKnock(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 60,
            ),
            SizedBox(
              height: 50,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 180,
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    // margin: const EdgeInsets.only(right: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        if (!mounted) return;
                        setState(() {
                          _currentPageIndex = index;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _currentPageIndex == index
                              ? const Color(0xff4B4B5A)
                              : Colors.white,
                          foregroundColor: _currentPageIndex == index
                              ? Colors.white
                              : const Color(0xff4B4B5A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          side: BorderSide(
                              width: _currentPageIndex == index ? 0 : 3,
                              color: const Color(0xff4B4B5A))),
                      child: Text(
                        _pageName[index],
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                  );
                },
              ),
            ),
            pages[_currentPageIndex],
          ],
        ),
      ),
    );
  }
}
