import 'package:flutter/material.dart';

// libraries import
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rive/rive.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/components/custom_clippers/post_title_card_clipper.dart';
import 'package:travelknock/components/custom_widgets/dialogs/report_dialog.dart';
import 'package:travelknock/screens/tabs.dart';

// screens import
import '../../../screens/plans/plan_details.dart';

class PlanCard extends StatefulWidget {
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
  State<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {
  final supabase = Supabase.instance.client;
  List _blockUsersList = [];

  void getBlockUser() async {
    if (supabase.auth.currentUser != null) {
      final List blockUsers = await supabase
          .from('profiles')
          .select('block_users')
          .eq('id', supabase.auth.currentUser!.id);
      _blockUsersList = blockUsers[0]['block_users'];
    }
  }

  @override
  void initState() {
    getBlockUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final likedPost = [];
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    void goToNoSignInScreen() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return const TabsScreen(initialPageIndex: 1,);
          },
        ),
      );
    }

    // Display posts!
    return widget.posts.isEmpty
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
            itemCount: widget.posts.length,
            padding: EdgeInsets.only(top: widget.listViewTopPadding),
            itemBuilder: (context, index) {
              List likes = widget.posts[index]['post_like_users'];
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
                  return _blockUsersList
                          .contains(widget.posts[index]['user_id'])
                      ? const SizedBox()
                      : GestureDetector(
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
                                    imageUrl: widget.posts[index]['thumbnail'],
                                    width: width * 0.8, // 400
                                    height: width >= 1000
                                        ? 300
                                        : height * 0.24, // 200
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[200]!,
                                      child: const SizedBox(),
                                    ),
                                  ),
                                ),
                                // like button
                                GestureDetector(
                                  onTap: () {
                                    widget.likePost(
                                        index, likeNumber, likedPost);
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
                                      // position: DecorationPosition.foreground,
                                      child: Center(
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: Stack(
                                                alignment:
                                                    Alignment.bottomRight,
                                                children: [
                                                  SizedBox(
                                                    width: 60,
                                                    height: 70,
                                                    child: RiveAnimation.asset(
                                                      widget.yourLikePostsData
                                                              .contains(widget
                                                                      .posts[
                                                                  index]['id'])
                                                          ? 'assets/rivs/rive-red-fire.riv'
                                                          : 'assets/rivs/rive-black-like-fire.riv',
                                                    ),
                                                  ),
                                                  // RIVEのロゴを隠すWidget
                                                  const SizedBox(
                                                    width: 22,
                                                    height: 5,
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xffF2F2F2),
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
                                          : height *
                                              0.155), // 130 height * 0.155
                                  child: Center(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        width >= 500
                                            ? Transform.scale(
                                                scale: 1,
                                                child: ClipPath(
                                                  clipper:
                                                      PostTitleCardClipper(),
                                                  child: Container(
                                                    width: width * 0.8,
                                                    height: width >= 1000
                                                        ? height * 0.15
                                                        : height * 0.1, // 100
                                                    color:
                                                        const Color(0xfff2f2f2),
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
                                                      widget.posts[index]
                                                          ['title']!,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                                  width: width >= 500
                                                      ? 200
                                                      : 120, // 120
                                                  height: width >= 500
                                                      ? 60
                                                      : 45, // 45
                                                  child: ElevatedButton(
                                                    onPressed: supabase.auth
                                                                .currentUser ==
                                                            null
                                                        ? goToNoSignInScreen
                                                        : supabase
                                                                    .auth
                                                                    .currentUser!
                                                                    .id ==
                                                                widget.posts[
                                                                        index]
                                                                    ['user_id']
                                                            ? null
                                                            : () async {
                                                                await widget
                                                                    .getUserInfo(
                                                                        index);
                                                                widget
                                                                    .showKnockPlan(
                                                                        index);
                                                              },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.black,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Knock plan',
                                                      style: TextStyle(
                                                        fontSize: width >= 500
                                                            ? 17
                                                            : 15,
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                // report UIs
                                Positioned(
                                  left: width >= 500
                                      ? width * 0.115
                                      : width >= 1000
                                          ? width * 0.115
                                          : width * 0.11, // 43
                                  right: width * 0.75, // 300
                                  top: width >= 1000
                                      ? height * 0.4
                                      : width >= 500
                                          ? height * 0.28
                                          : height * 0.25, // 210
                                  child: Container(
                                    width: 30,
                                    height: 60,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                                      color: Color(0xfff2f2f2),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                          Icons.warning_amber_outlined),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => ReportDialog(
                                              ownerId: widget.posts[index]
                                                  ['user_id']),
                                        );
                                      },
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
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
                  widget.getUserInfo(index);
                  return PlanDetailsScreen(
                    title: widget.posts[index]['title'],
                    thumbnail: widget.posts[index]['thumbnail'],
                    planDetailsList: widget.posts[index]['plans'],
                    ownerId: widget.posts[index]['user_id'],
                    placeName: widget.posts[index]['place_name'],
                    posts: widget.posts[index],
                    yourLikeData: widget.yourLikePostsData,
                    // ログインしていないユーザーが見れないのでnullありにし削除
                    // yourId: supabase.auth.currentUser!.id,
                  );
                },
              );
            },
          );
  }
}
