import 'package:flutter/material.dart';

// libraries import
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// screens import
import 'package:travelknock/screens/knock/profile_knock/knocked/knocked.dart';
import 'package:travelknock/screens/knock/profile_knock/your_knock.dart';
import 'package:travelknock/screens/profile/setting_profile/setting_profile.dart';
import '../../preferences/preferences_manager.dart';
import '../create_plan/new_plan.dart';
import '../login/login.dart';

// component import
import '../../components/custom_widgets/plans/custom_fab.dart';

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
    // width and height
    // final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              const Text(
                'Do you want to Sign Out?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  // color: Color(0xff4B4B5A),
                ),
              ),
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(top: 25),
                decoration: const BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: CachedNetworkImage(
                  imageUrl: _yourAvatar,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Container(
              width: 100,
              height: 50,
              margin: EdgeInsets.only(bottom: height * 0.03),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4B4B5A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Yes'),
                onPressed: () async {
                  await supabase.auth.signOut();
                  await PreferencesManager().setIsLogin(isLogin: false);

                  if (context.mounted) {
                    // Navigator.of(context)
                    // Sign Out後にホームに戻れてしまうからpushAndRemoveUntilで解消
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) {
                        return false;
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 30),
            Container(
              width: 100,
              height: 50,
              margin: EdgeInsets.only(bottom: height * 0.03),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff2f2f2),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('No'),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            )
          ],
        );
      },
    );
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    SystemChrome.setPreferredOrientations([
      //許可する向きを指定する。
      DeviceOrientation.portraitUp, //上向きを許可
    ]);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        // appBarの後ろにあるwidgetがタップできない問題を解消するためにtrueにするよ！！！
        forceMaterialTransparency: true,
        toolbarHeight: 90,
        actions: [
          Transform.rotate(
            // 回転しちゃうぞ
            angle: 0 * pi / 180,
            child: SizedBox(
              width: 80,
              height: 90,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    if (supabase.auth.currentUser == null) {
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) {
                            return const LoginScreen();
                          },
                        ),
                      );
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
        ],
      ),
      floatingActionButtonAnimator: AnimationNoScaling(),
      extendBodyBehindAppBar: true,
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 70,
                  ),
                  // DONE create profile page here and users can update own profile!!
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.07, bottom: 30),
                    child: SizedBox(
                      width: 100, // 100 width * 0.26
                      height: 40, // 40 height * 0.045
                      child: ElevatedButton(
                        onPressed: () {
                          // print('Pressed Profile Edit Button!');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const SettingProfileScreen(isEdit: true);
                              },
                            ),
                          );
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
                    margin: EdgeInsets.only(left: width * 0.07, bottom: 30),
                    child: const Text(
                      'Yours 🛠️',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: width * 0.84, // 330
                          height: width >= 500
                              ? height * 0.4
                              : height * 0.24, // 200
                          margin: const EdgeInsets.only(bottom: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          // 画像が設定されていなかったら雲の画像をset!!
                          child: CachedNetworkImage(
                            imageUrl: _yourHeader != null
                                ? _yourHeader!
                                : 'https://pmmgjywnzshfclavyeix.supabase.co/storage/v1/object/public/posts/6ab44cec-df53-4cc3-8c09-85907eb37815/IMG_8796.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          width: 120, // 120  width * 0.31
                          height: 120, // 120
                          decoration:
                              const BoxDecoration(shape: BoxShape.circle),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: CachedNetworkImage(
                            imageUrl: _yourAvatar,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02), // 10
                  Center(
                    child: Text(
                      _yourName,
                      style: TextStyle(
                        fontSize: width >= 500 ? 30 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02, // 15
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.07,
                        bottom: 20), // right: 210, bottom: 20
                    child: const Text(
                      'Your Places',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: width * 0.9, // 350
                    padding: EdgeInsets.only(left: width * 0.07),
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: _yourPlaces.length,
                      itemBuilder: (context, index) {
                        return Text(
                          index == (_yourPlaces.length - 1)
                              ? _yourPlaces[index]
                              : _yourPlaces[index] + ', ',
                          style: TextStyle(
                            fontSize: width >= 500 ? 18 : 15,
                            color: const Color(0xff7A7a7A),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.only(bottom: 40, left: width * 0.07),
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
                    // ),
                  ),
                  Center(
                    child: SizedBox(
                      height: height * 0.058, // 50
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: pages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: width * 0.46, // 180
                            padding: EdgeInsets.only(
                              left: width >= 500 ? 60 : 30,
                              right: width >= 500 ? 60 : 30,
                            ), // left: 30, right: 30
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
                  ),
                  pages[_currentPageIndex],
                ],
              ),
      ),
    );
  }
}
