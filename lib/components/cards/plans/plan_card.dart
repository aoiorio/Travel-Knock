import 'package:flutter/material.dart';

// libraries import
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rive/rive.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/components/custom_clippers/post_title_card_clipper.dart';

// screens import
import '../../../screens/login/login.dart';
import '../../../screens/plans/plan_details.dart';

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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    void goBackToLoginScreen() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return const LoginScreen();
          },
        ),
      );
    }

    // Display posts!
    return posts.isEmpty
        ? Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // DONE ADD stylish illustration!!!
                SizedBox(
                  width: width >= 1000 ? width * 0.5 : width,
                  // DONE change illustration
                  child: Image.asset('assets/images/no-posts.PNG'),
                ),
                // Image.asset("assets/images/no-posts.PNG"),
                const Text(
                  'No plans yet!!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30)
              ],
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
                closedBuilder: (BuildContext _, VoidCallback openContainer) {
                  return GestureDetector(
                    onTap: openContainer,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Card(
                            margin: EdgeInsets.only(
                                bottom: width >= 1000
                                    ? height * 0.2
                                    : height * 0.08,
                                top: height * 0.02,
                                right: width * 0.125,
                                left: width * 0.125), // 70 20 50 50
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(70),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: CachedNetworkImage(
                              key: UniqueKey(),
                              imageUrl: posts[index]['thumbnail'],
                              width: width * 0.8, // 400
                              height:
                                  width >= 1000 ? 300 : height * 0.24, // 200
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[200]!,
                                child: const SizedBox(),
                              ),
                            ),
                          ),
                          // like button
                          GestureDetector(
                            onTap: () {
                              likePost(index, likeNumber, likedPost);
                            },
                            child: Container(
                              width: 100, // 100 width * 0.25
                              height: height * 0.06, // 50
                              margin: EdgeInsets.only(
                                right: width * 0.08, // 30
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
                            padding: EdgeInsets.only(
                                top: width >= 1000 || width >= 500
                                    ? 230
                                    : height * 0.155), // 130 height * 0.155
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  width >= 500
                                      ? Transform.scale(
                                          scale: 1,
                                          child: ClipPath(
                                            clipper: PostTitleCardClipper(),
                                            child: Container(
                                              width: width * 0.8,
                                              height: width >= 1000
                                                  ? height * 0.15
                                                  : height * 0.1, // 100
                                              color: const Color(0xfff2f2f2),
                                            ),
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/post-shape.png'),
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
                                              width: width * 0.3, // 120
                                              //50 ここをいじったらtextが切り取られてしまうが、一行だけのtextはいい感じになる
                                              height: 50,
                                              child: Text(
                                                posts[index]['title']!,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // knock button
                                          Container(
                                            margin: EdgeInsets.only(
                                              top: width >= 500
                                                  ? height * 0.02
                                                  : height * 0.01,
                                              left: width >= 500
                                                  ? width * 0.09
                                                  : width * 0.03,
                                            ), // 5, 10
                                            width:
                                                width >= 500 ? 200 : 120, // 120
                                            height:
                                                width >= 500 ? 60 : 45, // 45
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
                                                          showKnockPlan(index);
                                                        },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                              ),
                                              child: Text(
                                                'Knock plan',
                                                style: TextStyle(
                                                  fontSize:
                                                      width >= 500 ? 17 : 15,
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
                    placeName: posts[index]['place_name'],
                    posts: posts[index],
                    yourLikeData: yourLikePostsData,
                    // ログインしていないユーザーが見れないのでnullありにし削除
                    // yourId: supabase.auth.currentUser!.id,
                  );
                },
              );
            },
          );
  }
}
