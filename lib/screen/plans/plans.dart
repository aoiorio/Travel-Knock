import 'package:flutter/material.dart';

import 'dart:math';
import 'dart:ui';
import '../login.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/components/custom_carousel_slider.dart';
import 'package:travelknock/screen/create_plan/new_plan.dart';
import 'package:travelknock/screen/plans/plan_details.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final supabase = Supabase.instance.client;
  List<List<Map<String, String>>> plans = [];
  List posts = [];

  void getPosts() async {
    posts = await supabase.from('posts').select('*');
    setState(() {
      posts = posts;
    });
    print('ポスト：${posts[0]}');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPosts();
  }

  @override
  Widget build(BuildContext context) {
    void signOut() async {
      await supabase.auth.signOut();

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }

    final hotPlacesList = [
      {
        'placeName': 'Okinawa',
        'imageUrl':
            'https://i.pinimg.com/564x/48/4c/fd/484cfdb7de2fc35e6f6661966befe970.jpg',
      },
      {
        'placeName': 'Osaka',
        'imageUrl':
            'https://i.pinimg.com/564x/93/ee/a0/93eea007958b53ecf4879366128b8753.jpg',
      },
      {
        'placeName': 'Thai',
        'imageUrl':
            'https://i.pinimg.com/564x/a8/a5/61/a8a5619a67d3502ff7eb1057137a784f.jpg',
      },
      {
        'placeName': 'Gifu',
        'imageUrl':
            'https://i.pinimg.com/564x/2a/19/ee/2a19ee26bd2f285c5e5f31da4840db11.jpg',
      }
    ];

    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;

    return Scaffold(
      floatingActionButton: Transform.rotate(
        // 回転しちゃうぞ
        angle: -1 * pi / 180,
        child: Container(
          padding: const EdgeInsets.only(
            left: 300,
            // top: 60,
          ),
          child: SizedBox(
            width: 90,
            height: 90,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const NewPlanScreen();
                    },
                  ),
                );
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
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 25, top: 130),
                  child: Text(
                    "Let's Knock🚪",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            // CarouselSlider
            const CustomCarouselSlider(),
            const SizedBox(
              height: 30,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 25),
              child: Text(
                "🔥",
                style: TextStyle(
                  fontSize: 50,
                ),
              ),
            ),
            // todo Hot Places
            Container(
              margin: const EdgeInsets.only(
                top: 25,
              ),
              height: 200,
              width: double.infinity,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hotPlacesList.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 100.0,
                  crossAxisSpacing: 20.0,
                  mainAxisSpacing: 20.0,
                  childAspectRatio: (itemWidth / itemHeight),
                ),
                itemBuilder: (context, index) {
                  // TODO add InkWell to transition to detail_page
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    margin: const EdgeInsets.only(left: 20, right: 10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: Image.network(
                            hotPlacesList[index]['imageUrl']!,
                            fit: BoxFit.cover,
                            width: 200,
                            height: 100,
                          ),
                        ),
                        Center(
                          child: Text(
                            hotPlacesList[index]['placeName']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            posts == null
                ? const SizedBox()
                :
                // todo plans
                ListView.builder(
                    shrinkWrap: true, //追加
                    physics: const NeverScrollableScrollPhysics(), //追加ƒ
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return PlanDetailsScreen(
                                  title: posts[index]['title'],
                                  thumbnail: posts[index]['thumbnail'],
                                  planDetailsList: posts[index]['plans'],
                                );
                              },
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Card(
                              margin: const EdgeInsets.only(
                                  bottom: 70, top: 20, right: 50, left: 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(70),
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Image.network(
                                posts[index]['thumbnail']!,
                                width: 400,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              width: 100,
                              height: 50,
                              margin: const EdgeInsets.only(
                                right: 30,
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: const Color(0xffF2F2F2),
                                ),
                                position: DecorationPosition.background,
                                child: Center(
                                  child: Row(
                                    children: [
                                      IconButton(
                                        // TODO implement like features
                                        onPressed: () {
                                          print('Liked!!');
                                        },
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        icon: const Icon(
                                          Icons.local_fire_department,
                                          size: 30,
                                        ),
                                      ),
                                      const Text(
                                        '103',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 130),
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset('assets/images/post-shape.png'),
                                    Wrap(
                                      spacing: 40,
                                      alignment: WrapAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: SizedBox(
                                                width: 120,
                                                height:
                                                    50, // ここをいじったらtextが切り取られてしまうが、一行だけのtextはいい感じになる
                                                child: Text(
                                                  posts[index]['title']!,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 5, left: 10),
                                              width: 120,
                                              height: 45,
                                              child: ElevatedButton(
                                                onPressed: () {},
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.black,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Knock plan',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
