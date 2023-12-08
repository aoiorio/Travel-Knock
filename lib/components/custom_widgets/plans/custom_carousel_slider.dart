import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../screens/plans/plan_details.dart';

class CustomCarouselSlider extends StatefulWidget {
  const CustomCarouselSlider({super.key});

  @override
  State<CustomCarouselSlider> createState() => _CustomCarouselSliderState();
}

class _CustomCarouselSliderState extends State<CustomCarouselSlider> {
  final supabase = Supabase.instance.client;
  final controller = PageController(viewportFraction: 1.0, initialPage: 1000);
  List _posts = [];
  var isLoading = false;
  String _userAvatar = '';
  String _userName = '';
  var isZero = true;
  final _yourLikePostsData = [];

  Future getUserInfo(int index) async {
    if (!mounted) return;
    final userAvatar = await supabase
        .from('profiles')
        .select('avatar_url')
        .eq('id', _posts[index]['user_id'])
        .single();
    setState(() {
      _userAvatar = userAvatar['avatar_url'];
    });
    final userName = await supabase
        .from('profiles')
        .select('username')
        .eq('id', _posts[index]['user_id'])
        .single();
    setState(() {
      _userName = userName['username'];
    });
  }

  void getLikePosts() async {
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
    });
  }

  void getCarouselPosts() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    final posts = await supabase
        .from('posts')
        .select('*')
        .order('id', ascending: false)
        .limit(5);
    setState(() {
      _posts = posts;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getCarouselPosts();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // DONE change to CarouselSlider.builder, after finish connecting to the database
    return isLoading
        ? Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[200]!,
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: width * 0.9, // 350
                    height: width >= 1000 ? 400 : height * 0.33, // 270
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Container(
                    width: 150,
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Column(
            children: [
              SizedBox(
                height: width >= 1000 ? 400 : height * 0.33, // 270
                child: PageView.builder(
                  controller: controller,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.only(
                          right: width * 0.05, left: width * 0.05), // 20, 20
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            CachedNetworkImage(
                              key: UniqueKey(),
                              imageUrl: _posts[index % _posts.length]
                                  ['thumbnail'],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: width * 0.07,
                                bottom: height * 0.035,
                              ), // height * 0.22, right: 30, bottom: 30, left: 30
                              child: Row(
                                children: [
                                  Container(
                                    width: width * 0.55, // 210
                                    height: height * 0.07, // 60
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: const Color(0xff757585),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _posts[index % _posts.length]['title']
                                            .toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: width * 0.08,
                                  ),
                                  Container(
                                    width: width * 0.13, // 50
                                    height: 70, // 70
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color(0xff4B4B5A),
                                    ),
                                    child: IconButton(
                                      // DONE replace transition to the page of details
                                      onPressed: () {
                                        getUserInfo(index % _posts.length).then(
                                          (value) {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) {
                                                return PlanDetailsScreen(
                                                  title: _posts[index %
                                                      _posts.length]['title'],
                                                  thumbnail: _posts[
                                                          index % _posts.length]
                                                      ['thumbnail'],
                                                  planDetailsList: _posts[
                                                          index % _posts.length]
                                                      ['plans'],
                                                  ownerId: _posts[index %
                                                      _posts.length]['user_id'],
                                                  placeName: _posts[
                                                          index % _posts.length]
                                                      ['place_name'],
                                                  posts: _posts[
                                                      index % _posts.length],
                                                  yourLikeData:
                                                      _yourLikePostsData,
                                                );
                                              },
                                            ));
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: width >= 1000 ? 40 : 30,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: SmoothPageIndicator(
                  controller: controller,
                  count: _posts.length,
                  effect: const ExpandingDotsEffect(
                    dotColor: Color.fromARGB(255, 223, 223, 223),
                    activeDotColor: Color.fromARGB(255, 223, 223, 223),
                  ),
                ),
              ),
            ],
          );
  }
}
