import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screen/login.dart';
import '../screen/plans/plan_details.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.posts,
    required this.likePost,
    required this.yourLikePostsData,
    required this.showKnockPlan,
    required this.getUserInfo,
    required this.listViewTopPadding,
  });

  final List posts;
  final Function likePost;
  final List yourLikePostsData;
  final Function showKnockPlan;
  final Function getUserInfo;
  final double listViewTopPadding;

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final likedPost = [];

    void goBackToLoginScreen() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return const LoginScreen();
          },
        ),
      );
    }

    return // Display posts!
        posts.isEmpty
            ? Center(
                child: Container(
                  margin: const EdgeInsets.all(100),
                  // TODO ADD stylish illustration!!!
                  child: const Text(
                    'No plans yet!!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            :
            // DONE plans
            // DONE add GestureDetector to transition to detail_page
            ListView.builder(
                shrinkWrap: true, //追加
                physics: const NeverScrollableScrollPhysics(), //追加ƒ
                itemCount: posts.length,
                padding: EdgeInsets.only(top: listViewTopPadding),
                itemBuilder: (context, index) {
                  List likes = posts[index]['post_like_users'];
                  int likeNumber = likes.length;
                  return OpenContainer(
                    transitionType: ContainerTransitionType.fadeThrough,
                    closedColor: Colors.transparent,
                    openColor: Colors.transparent,
                    openElevation: 0,
                    closedElevation: 0,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    transitionDuration: const Duration(milliseconds: 400),
                    middleColor: Colors.transparent,
                    closedBuilder:
                        (BuildContext _, VoidCallback openContainer) {
                      return GestureDetector(
                        onTap: openContainer,
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
                              child: CachedNetworkImage(
                                key: UniqueKey(),
                                imageUrl: posts[index]['thumbnail'],
                                width: 400,
                                height: 200,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[200]!,
                                  child: const SizedBox(),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                likePost(index, likeNumber, likedPost);
                              },
                              child: Container(
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
                                        Container(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              SizedBox(
                                                width: 70,
                                                height: 70,
                                                child: RiveAnimation.asset(
                                                  yourLikePostsData.contains(
                                                          posts[index]['id'])
                                                      ? 'assets/rivs/rive-red-fire.riv'
                                                      : 'assets/rivs/rive-black-like-fire.riv',
                                                ),
                                              ),
                                              // RIVEのロゴを隠すWidget
                                              const SizedBox(
                                                width: 27,
                                                height: 5,
                                                child: DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    color: Color(0xffF2F2F2),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Text(
                                          likeNumber.toString(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
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
                                                onPressed: supabase
                                                            .auth.currentUser ==
                                                        null
                                                    ? goBackToLoginScreen
                                                    : supabase.auth.currentUser!
                                                                .id ==
                                                            posts[index]
                                                                ['user_id']
                                                        ? null
                                                        : () async {
                                                            await getUserInfo(
                                                                index);
                                                            showKnockPlan(
                                                                index);
                                                          },
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
                    openBuilder: (BuildContext _, VoidCallback __) {
                      // avatarを取得し終わってから遷移する
                      getUserInfo(index);
                      return PlanDetailsScreen(
                        title: posts[index]['title'],
                        thumbnail: posts[index]['thumbnail'],
                        planDetailsList: posts[index]['plans'],
                        ownerId: posts[index]['user_id'],
                        // ログインしていないユーザーが見れないのでnullありにし削除
                        // yourId: supabase.auth.currentUser!.id,
                      );
                    },
                  );
                },
              );
  }
}
