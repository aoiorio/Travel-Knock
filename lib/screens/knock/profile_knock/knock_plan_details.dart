import 'package:flutter/material.dart';

// libraries import
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// screens import
import 'package:travelknock/screens/login/login.dart';
import 'package:travelknock/screens/profile/user_profile.dart';

// components import
import 'package:travelknock/components/custom_clippers/details_clipper.dart';
import 'package:travelknock/components/cards/plans/plan_details_card.dart';

class KnockPlanDetailsScreen extends StatefulWidget {
  const KnockPlanDetailsScreen({
    super.key,
    required this.title,
    required this.thumbnail,
    required this.planDetailsList,
    required this.requestedUserAvatar,
    required this.requestedUserName,
    required this.requestedUserId,
    required this.yourAvatar,
    required this.yourName,
    required this.isYourKnock,
  });

  final String title;
  final String thumbnail;
  final List planDetailsList;
  final String requestedUserAvatar;
  final String requestedUserName;
  final String requestedUserId;
  final String yourAvatar;
  final String yourName;
  final bool isYourKnock;

  @override
  State<KnockPlanDetailsScreen> createState() => _KnockPlanDetailsScreenState();
}

class _KnockPlanDetailsScreenState extends State<KnockPlanDetailsScreen> {
  var _selectedDayIndex = 0;
  var _isSelected = [true, false];
  final List _yourLikePostsData = [];
  List<List<Map<String, dynamic>>> plans = [];
  var heroTag = '';
  final supabase = Supabase.instance.client;

  void goBackToLoginScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return const LoginScreen();
      },
    ));
  }

  // 受け取ったリストの中のリストのマップが文字列になっていたからマップに変える関数
  List<List<Map<String, dynamic>>> convertStringToMap(
      List<dynamic> planDetailsList) {
    final index = planDetailsList.length;
    List<List<Map<String, dynamic>>> dayPlans =
        List.generate(index, (index) => []);

    for (var i = 0; index > i; i++) {
      List dayPlanList = planDetailsList[i];
      var stringCount = dayPlanList.length;
      for (var j = 0; stringCount > j; j++) {
        String imitationMap = dayPlanList[j];
        dynamic decodedMap = json.decode(imitationMap);
        dayPlans[i].add(decodedMap);
      }
    }
    return dayPlans;
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

  @override
  void initState() {
    super.initState();
    // 最初に選択されているDayは1日目というのを設定している
    _isSelected = List.generate(widget.planDetailsList.length, (index) {
      if (index == 0) {
        return true;
      }
      return false;
    });
    plans = convertStringToMap(widget.planDetailsList);
    heroTag = widget.thumbnail;
    getLikePosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Hero(
                  tag: heroTag,
                  child: Transform.scale(
                    scale: MediaQuery.of(context).size.width / 385, // 1.03
                    child: ClipPath(
                      clipper: DetailsClipper(),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.only(top: 0, left: 0),
                          width: double.infinity,
                          height: 366,
                          child: CachedNetworkImage(
                            key: UniqueKey(),
                            imageUrl: widget.thumbnail,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              decoration:
                                  const BoxDecoration(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 150),
                        width: 150,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration:
                                  const BoxDecoration(shape: BoxShape.circle),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: widget.requestedUserAvatar.isEmpty
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[200]!,
                                      child:
                                          const ColoredBox(color: Colors.grey),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        if (!mounted) return;
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserProfileScreen(
                                              userId: widget.isYourKnock
                                                  ? supabase
                                                      .auth.currentUser!.id
                                                  : widget.requestedUserId,
                                              // yourLikePostsData: _yourLikePostsData,
                                            ),
                                          ),
                                        );
                                      },
                                      child: CachedNetworkImage(
                                        imageUrl: widget.isYourKnock
                                            ? widget.yourAvatar
                                            : widget.requestedUserAvatar
                                                .toString(),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            widget.requestedUserName.isEmpty
                                ? Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[200]!,
                                    child: Container(
                                      width: 50,
                                      height: 30,
                                      decoration: const BoxDecoration(
                                          color: Colors.white),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      widget.isYourKnock
                                          ? widget.yourName
                                          : widget.requestedUserName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      const Icon(Icons.multiple_stop),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 150),
                        width: 150,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration:
                                  const BoxDecoration(shape: BoxShape.circle),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: widget.yourAvatar.isEmpty
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[200]!,
                                      child:
                                          const ColoredBox(color: Colors.grey),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        if (!mounted) return;
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserProfileScreen(
                                              userId: widget.isYourKnock
                                                  ? widget.requestedUserId
                                                  : supabase
                                                      .auth.currentUser!.id,
                                              // yourLikePostsData: _yourLikePostsData,
                                            ),
                                          ),
                                        );
                                      },
                                      child: CachedNetworkImage(
                                        imageUrl: widget.isYourKnock
                                            ? widget.requestedUserAvatar
                                            : widget.yourAvatar,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            widget.yourName.isEmpty
                                ? Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[200]!,
                                    child: Container(
                                      width: 50,
                                      height: 30,
                                      decoration: const BoxDecoration(
                                          color: Colors.white),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      widget.isYourKnock
                                          ? widget.requestedUserName
                                          : widget.yourName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(
                  top: 0, right: 25, left: 35, bottom: 10),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Days
            Container(
              padding: const EdgeInsets.only(top: 40, left: 20, right: 10),
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ToggleButtons(
                    direction: Axis.horizontal,
                    isSelected: _isSelected,
                    onPressed: (int index) {
                      // The button that is tapped is set to true, and the others to false.
                      setState(() {
                        for (int i = 0; i < _isSelected.length; i++) {
                          _isSelected[i] = i == index;
                        }
                        _selectedDayIndex = index;
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    selectedBorderColor: const Color(0xff4B4B5A),
                    selectedColor: Colors.white,
                    fillColor: const Color(0xff4B4B5A),
                    color: const Color(0xff4B4B5A),
                    focusColor: const Color(0xff4B4B5A),
                    hoverColor: const Color(0xff4B4B5A),
                    splashColor: const Color.fromARGB(255, 104, 104, 115),
                    constraints: const BoxConstraints(
                      minHeight: 80.0,
                      minWidth: 120.0,
                    ),
                    children: List.generate(
                      widget.planDetailsList.length,
                      (index) => Text(
                        '${index + 1} Day',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PlanDetailsCard(
                planList: plans[_selectedDayIndex], isDevelop: false),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
