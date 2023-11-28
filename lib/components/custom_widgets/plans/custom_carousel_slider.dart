import 'package:flutter/material.dart';

// libraries import
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// screen import
import 'package:travelknock/screens/plans/plan_details.dart';

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
    // TODO: implement initState
    super.initState();
    getCarouselPosts();
  }

  @override
  Widget build(BuildContext context) {
    // DONE change to CarouselSlider.builder, after finish connecting to the database
    return isLoading
        ? Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[200]!,
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 350,
                    height: 270,
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
                height: 270,
                child: PageView.builder(
                  controller: controller,
                  itemBuilder: (context, index) {
                    return Card(
                      margin:
                          const EdgeInsets.only(right: 20, left: 20, bottom: 0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              key: UniqueKey(),
                              imageUrl: _posts[index % _posts.length]
                                  ['thumbnail'],
                              width: 500,
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 180, right: 30, bottom: 30, left: 30),
                              child: Row(
                                children: [
                                  Container(
                                    width: 210,
                                    height: 60,
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
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  Container(
                                    width: 50,
                                    height: 70,
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
                                                  yourId: supabase.auth.currentUser!.id,
                                                );
                                              },
                                            ));
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
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
              const SizedBox(
                height: 30,
              ),
              Center(
                child: SmoothPageIndicator(
                  controller: controller,
                  count: _posts.length,
                  effect: const ExpandingDotsEffect(
                      dotColor: Color.fromARGB(255, 223, 223, 223),
                      activeDotColor: Color.fromARGB(255, 223, 223, 223)),
                ),
              )
            ],
          );
  }
}
