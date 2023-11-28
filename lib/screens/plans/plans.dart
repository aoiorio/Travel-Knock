import 'package:flutter/material.dart';

// libraries import
import 'dart:math';
import 'dart:ui';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

// screens import
import 'package:travelknock/screens/search/search.dart';
import 'package:travelknock/screens/tabs.dart';
import 'package:travelknock/screens/create_plan/new_plan.dart';
import '../knock/knock_plan.dart';
import '../login/login.dart';

// components import
import 'package:travelknock/components/cards/plans/plan_card.dart';
import 'package:travelknock/components/custom_widgets/plans/custom_carousel_slider.dart';
import '../../components/custom_widgets/plans/custom_fab.dart';



class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final supabase = Supabase.instance.client;
  List<List<Map<String, String>>> plans = [];
  List posts = [];
  String _userAvatar = '';
  String _userName = '';
  final List _yourLikePostsData = [];
  List likedPost = [];
  List _hotPlaceList = [];

  Future<void> getPosts() async {
    if (!mounted) return;
    posts = await supabase
        .from('posts')
        .select('*')
        .order('likes', ascending: false);
    setState(() {
      posts = posts;
    });
  }

  Future getUserInfo(int index) async {
    if (!mounted) return;
    final userAvatar = await supabase
        .from('profiles')
        .select('avatar_url')
        .eq('id', posts[index]['user_id'])
        .single();
    setState(() {
      _userAvatar = userAvatar['avatar_url'];
    });
    final userName = await supabase
        .from('profiles')
        .select('username')
        .eq('id', posts[index]['user_id'])
        .single();
    setState(() {
      _userName = userName['username'];
    });
  }

  void showKnockPlan(int index) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(70),
          topLeft: Radius.circular(70),
        ),
      ),
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return KnockPlanScreen(
          ownerAvatar: _userAvatar,
          ownerName: _userName,
          requestUserId: supabase.auth.currentUser!.id,
          ownerId: posts[index]['user_id'],
        );
      },
    );
  }

  void likePost(int index, int likeNumber, List likedPost) async {
    // まず、登録をしていないお客様はこちらへどうぞ
    if (supabase.auth.currentUser == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const TabsScreen(initialPageIndex: 1),
        ),
      );
      return;
    }
    final userId = supabase.auth.currentUser!.id;

    // userは自分の投稿したpostにいいねできない
    if (userId == posts[index]['user_id']) {
      return;
    }

    List userList = posts[index]['post_like_users'];
    final likes = await supabase
        .from('posts')
        .select('likes')
        .eq('id', posts[index]['id'])
        .single();

    try {
      if (userList.contains(userId)) {
        userList.remove(userId);
        await supabase
            .from('posts')
            .update({'likes': likes['likes'] - 1}).eq('id', posts[index]['id']);
        setState(() {
          likeNumber -= 1;
        });
      } else {
        userList.add(userId);
        await supabase
            .from('posts')
            .update({'likes': likes['likes'] + 1}).eq('id', posts[index]['id']);
        setState(() {
          likeNumber++;
        });
      }
      await supabase
          .from('posts')
          .update({'post_like_users': userList}).eq('id', posts[index]['id']);

      final aLikedPost = await supabase
          .from('likes')
          .select('id')
          .eq('post_id', posts[index]['id'])
          .eq('user_id', supabase.auth.currentUser!.id);
      setState(() {
        likedPost = aLikedPost;
      });
      // 数字が変わるのと、アイコンの色が変わるのが別々で耐え難かったからこちらに移動 => いや、機能しないやん

      // userがその投稿にいいねをしていたらreturnする
      if (likedPost.isNotEmpty) {
        setState(() {
          _yourLikePostsData.remove(posts[index]['id']);
        });
        await supabase.from('likes').delete().eq('id', likedPost[0]['id']);
        return;
      }
      setState(() {
        _yourLikePostsData.add(posts[index]['id']);
      });
      await supabase.from('likes').insert({
        'user_id': supabase.auth.currentUser!.id,
        'post_id': posts[index]['id'],
      });
    } catch (e) {
      print('error: $e');
    }
  }

  void getLikePosts() async {
    if (!mounted) return;
    if (supabase.auth.currentUser == null) return;
    final List yourLikePostsData = await supabase
        .from('likes')
        .select('post_id')
        .eq('user_id', supabase.auth.currentUser!.id);
    setState(() {
      for (var i = 0;
          _yourLikePostsData.length < yourLikePostsData.length;
          i++) {
        _yourLikePostsData.add(yourLikePostsData[i]['post_id']);
      }
      print('_yourLikePostsData$_yourLikePostsData');
    });
  }

  void goBackToLoginScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return const LoginScreen();
      },
    ));
  }

  // it's the most attractive places in Travel Knock
  void getHotPlace() async {
    if (!mounted) return;
    final duplicatedPlaceList = [];
    final hotPlaceList = [];
    for (var i = 0; posts.length > i; i++) {
      // if (duplicatedPlaceList.contains(posts[i]['place_name'])) return;
      final List placeCountList = await supabase
          .from('posts')
          .select('*')
          .eq('place_name', posts[i]['place_name']);
      if (placeCountList.length > 1 &&
          !duplicatedPlaceList.contains(posts[i]['place_name']) &&
          hotPlaceList.length < 7) {
        duplicatedPlaceList.add(posts[i]['place_name']);
        setState(() {
          hotPlaceList.add(posts[i]);
        });
      }
    }
    setState(() {
      _hotPlaceList = hotPlaceList;
    });
  }

  @override
  void initState() {
    super.initState();
    getLikePosts();
    getPosts().then((value) => getHotPlace());
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return SearchScreen(
                      yourLikePostsData: _yourLikePostsData,
                    );
                  },
                ),
              );
            },
            icon: const Icon(
              Icons.search,
              color: Colors.black,
              size: 40,
            ),
          ),
        ),
      ),
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
          size.width / 15,
          0), // FloatingActionButtonLocation.miniEndTop 20
      floatingActionButtonAnimator: AnimationNoScaling(),

      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        onRefresh: () async {
          await getPosts();
          getLikePosts();
        },
        child: SingleChildScrollView(
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
              const SizedBox(height: 30),
              // CarouselSlider
              const CustomCarouselSlider(),
              const SizedBox(height: 5),
              const Padding(
                padding: EdgeInsets.only(left: 25),
                child: Text(
                  "🔥",
                  style: TextStyle(
                    fontSize: 50,
                  ),
                ),
              ),
              // DONE Hot Places
              _hotPlaceList.isEmpty
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        margin: const EdgeInsets.only(top: 25),
                        height: 200,
                        width: double.infinity,
                        child: GridView.builder(
                          itemCount: 4,
                          scrollDirection: Axis.horizontal,
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 100.0,
                            crossAxisSpacing: 20.0,
                            mainAxisSpacing: 20.0,
                            childAspectRatio: (itemWidth / itemHeight),
                          ),
                          itemBuilder: (context, index) {
                            return Card(
                              margin:
                                  const EdgeInsets.only(left: 20, right: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.only(top: 25),
                      height: 200,
                      width: double.infinity,
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _hotPlaceList.length,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 100.0,
                          crossAxisSpacing: 20.0,
                          mainAxisSpacing: 20.0,
                          childAspectRatio: (itemWidth / itemHeight),
                        ),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SearchScreen(
                                      yourLikePostsData: _yourLikePostsData,
                                      searchText: _hotPlaceList[index]
                                          ['place_name'],
                                    );
                                  },
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              margin:
                                  const EdgeInsets.only(left: 20, right: 10),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ImageFiltered(
                                    imageFilter:
                                        ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                                    child: CachedNetworkImage(
                                      imageUrl: _hotPlaceList[index]
                                          ['thumbnail'],
                                      fit: BoxFit.cover,
                                      width: 200,
                                      height: 100,
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      _hotPlaceList[index]['place_name'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

              // display user posts
              PlanCard(
                posts: posts,
                likePost: likePost,
                yourLikePostsData: _yourLikePostsData,
                showKnockPlan: showKnockPlan,
                getUserInfo: getUserInfo,
                listViewTopPadding: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
