// DONE create profile page
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/screen/knock/knocked.dart';
import 'package:travelknock/screen/knock/your_knock.dart';
import 'package:travelknock/screen/setting_profile.dart';

import '../components/custom_fab.dart';
import 'create_plan/new_plan.dart';
import 'login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});



  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ここにもgeUserLikePostsで取得した_yourLikePostsDataを持ってきたいいんじゃね？？？
  final supabase = Supabase.instance.client;
  List<Widget> pages = [];
  int _currentPageIndex = 0;
  final List<String> _pageName = ['Knocked', 'Your Knock'];
  String _yourAvatar = '';
  String _yourName = '';
  List _yourPlaces = [];
  bool _isLoading = false;
  String? _yourHeader;

  Future getYourInfo() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    final yourData = await supabase
        .from('profiles')
        .select('*')
        .eq('id', supabase.auth.currentUser!.id)
        .single();
    setState(() {
      _yourAvatar = yourData['avatar_url'];
      _yourName = yourData['username'];
      _yourPlaces = yourData['places'];
      _yourHeader = yourData['header_url'];
      _isLoading = false;
    });
  }

  void signOut() async {
    if (!mounted) return;
    await supabase.auth.signOut();

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    getYourInfo().then((value) {
      setState(() {
        pages = [
          KnockedScreen(yourAvatar: _yourAvatar, yourName: _yourName),
          YourKnock(
            yourAvatar: _yourAvatar,
            yourName: _yourName,
          ),
        ];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Transform.rotate(
        // 回転しちゃうぞ
        angle: -1 * pi / 180,
        child: Container(
          margin: const EdgeInsets.only(right: 0),
          child: SizedBox(
            width: 90,
            height: 90,
            child: ElevatedButton(
              onPressed: () async {
                if (!mounted) return;
                try {
                  if (supabase.auth.currentUser == null) {
                    await Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(
                      builder: (context) {
                        return const LoginScreen();
                      },
                    ));
                  }
                } on Exception {
                  print('anonymous');
                }
                try {
                  if (!mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const NewPlanScreen();
                      },
                    ),
                  );
                } on Exception {
                  print('anonymous!');
                }
              },
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
      floatingActionButtonLocation: CustomizeFloatingLocation(
          FloatingActionButtonLocation.miniEndTop,
          MediaQuery.of(context).size.width / 15,
          0),
      floatingActionButtonAnimator: AnimationNoScaling(),
      body: SingleChildScrollView(
        child: _isLoading
            ? Center(
                child: Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 2),
                  child: const CircularProgressIndicator(
                    color: Color(0xff4B4B5A),
                  ),
                ),
              )
            : Column(
                children: [
                  const SizedBox(
                    height: 70,
                  ),
                  // TODO create profile page here and users can update own profile!!
                  Padding(
                    padding: const EdgeInsets.only(right: 240, bottom: 30),
                    child: SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          print('Pressed Profile Edit Button!');
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return const SettingProfileScreen(isEdit: true);
                            },
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 200, bottom: 30),
                    child: const Text(
                      'Yours 🛠️',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: 330,
                        height: 200,
                        margin: const EdgeInsets.only(bottom: 30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: CachedNetworkImage(
                          imageUrl: _yourHeader != null
                              ? _yourHeader!
                              : 'https://pmmgjywnzshfclavyeix.supabase.co/storage/v1/object/public/posts/6ab44cec-df53-4cc3-8c09-85907eb37815/IMG_8796.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: CachedNetworkImage(
                          imageUrl: _yourAvatar,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _yourName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 210, bottom: 20),
                    child: Text(
                      'Your Places',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 350,
                    padding: const EdgeInsets.only(left: 15),
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: _yourPlaces.length,
                      itemBuilder: (context, index) {
                        return Text(
                          index == (_yourPlaces.length - 1)
                              ? _yourPlaces[index]
                              : _yourPlaces[index] + ', ',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xff7A7a7A),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40, right: 200),
                    child: Center(
                      child: SizedBox(
                        height: 40,
                        width: 120,
                        child: ElevatedButton(
                          // DONE create a transition to PlansScreen and add details to the database
                          onPressed: signOut,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffF2F2F2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              )),
                          child: const Text(
                            'Sign Out',
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 128, 76, 72)),
                          ),
                        ),
                      ),
                    ),
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
                                    : const Color(0xfffafafa),
                                foregroundColor: _currentPageIndex == index
                                    ? const Color(0xfffafafa)
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
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
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
