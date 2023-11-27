import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:rive/rive.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/components/custom_clipper.dart';

import 'dart:convert';

import 'package:travelknock/components/plan_details_card.dart';
import 'package:travelknock/screen/knock/knock_plan.dart';
import 'package:travelknock/screen/login.dart';
import 'package:travelknock/screen/user_profile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../tabs.dart';

class PlanDetailsScreen extends StatefulWidget {
  const PlanDetailsScreen({
    super.key,
    required this.title,
    required this.thumbnail,
    required this.planDetailsList,
    this.yourId,
    required this.ownerId,
    required this.placeName,
    required this.posts,
    required this.yourLikeData,
  });

  final String title;
  final String thumbnail;
  final List planDetailsList;
  final String placeName;
  final Map posts;
  final List yourLikeData;
  final String? yourId;
  final String ownerId;

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  final supabase = Supabase.instance.client;
  var _selectedDayIndex = 0;
  var _isSelected = [true, false];
  List<List<Map<String, dynamic>>> plans = [];
  var heroTag = '';
  String _ownerAvatar = '';
  String _ownerName = '';
  List _yourLikePostsData = [];
  final _likedPost = [];
  // final String _ownerId = '';

  void goBackToLoginScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return const LoginScreen();
      },
    ));
  }

  void getOwnerInfo() async {
    final ownerAvatar = await supabase
        .from('profiles')
        .select('avatar_url')
        .eq('id', widget.ownerId)
        .single();
    final ownerName = await supabase
        .from('profiles')
        .select('username')
        .eq('id', widget.ownerId)
        .single();
    setState(() {
      _ownerAvatar = ownerAvatar['avatar_url'];
      _ownerName = ownerName['username'];
    });
  }

  void likePost(int likeNumber, List likedPost) async {
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
    if (userId == widget.posts['user_id']) {
      return;
    }

    List userList = widget.posts['post_like_users'];
    final likes = await supabase
        .from('posts')
        .select('likes')
        .eq('id', widget.posts['id'])
        .single();

    try {
      if (userList.contains(userId)) {
        userList.remove(userId);
        await supabase
            .from('posts')
            .update({'likes': likes['likes'] - 1}).eq('id', widget.posts['id']);
        setState(() {
          likeNumber -= 1;
        });
      } else {
        userList.add(userId);
        await supabase
            .from('posts')
            .update({'likes': likes['likes'] + 1}).eq('id', widget.posts['id']);
        setState(() {
          likeNumber++;
        });
      }
      await supabase
          .from('posts')
          .update({'post_like_users': userList}).eq('id', widget.posts['id']);

      final aLikedPost = await supabase
          .from('likes')
          .select('id')
          .eq('post_id', widget.posts['id'])
          .eq('user_id', supabase.auth.currentUser!.id);
      setState(() {
        likedPost = aLikedPost;
      });
      // 数字が変わるのと、アイコンの色が変わるのが別々で耐え難かったからこちらに移動 => いや、機能しないやん

      // userがその投稿にいいねをしていたらreturnする
      if (likedPost.isNotEmpty) {
        setState(() {
          _yourLikePostsData.remove(widget.posts['id']);
        });
        await supabase.from('likes').delete().eq('id', likedPost[0]['id']);
        return;
      }
      setState(() {
        _yourLikePostsData.add(widget.posts['id']);
      });
      await supabase.from('likes').insert({
        'user_id': supabase.auth.currentUser!.id,
        'post_id': widget.posts['id'],
      });
    } catch (e) {
      print('error: $e');
    }
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
    getOwnerInfo();
    _yourLikePostsData = widget.yourLikeData;
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

  void showKnockPlan() {
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
          ownerAvatar: _ownerAvatar,
          ownerName: _ownerName,
          requestUserId: supabase.auth.currentUser!.id,
          ownerId: widget.ownerId,
        );
      },
    );
  }

  void _openLink() async {
    const url = 'http://abehiroshi.la.coocan.jp/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _openReportForm() async {
    final url = Uri.parse("https://forms.gle/1fgkioJvsF3uWkpf7");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not Launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // forBun();
    List likes = widget.posts['post_like_users'];
    int likeNumber = likes.length;

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          actions: widget.ownerId == supabase.auth.currentUser!.id
              ? null
              : [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      onPressed: _openReportForm,
                      icon: const Icon(
                        Icons.warning_amber_outlined,
                      ),
                    ),
                  ),
                ],
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
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        margin: const EdgeInsets.only(left: 35),
                        child: _ownerAvatar.isEmpty
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[200]!,
                                child: const ColoredBox(color: Colors.grey),
                              )
                            : GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return UserProfileScreen(
                                          userId: widget.ownerId,
                                          yourLikePostsData: _yourLikePostsData,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: CachedNetworkImage(
                                  imageUrl: _ownerAvatar.toString(),
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      _ownerName.isEmpty
                          ? Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[200]!,
                              child: Container(
                                width: 50,
                                height: 30,
                                decoration:
                                    const BoxDecoration(color: Colors.white),
                              ),
                            )
                          : _ownerName.length >= 9
                              ? SingleChildScrollView(
                                  child: SizedBox(
                                    height: 37,
                                    width: 60,
                                    child: Text(
                                      _ownerName,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  width: 60,
                                  child: Text(
                                    _ownerName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                      const SizedBox(width: 20),
                      // Knock button
                      Container(
                        margin: const EdgeInsets.only(top: 5, left: 10),
                        width: 145,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: supabase.auth.currentUser == null
                              ? goBackToLoginScreen
                              : supabase.auth.currentUser!.id == widget.ownerId
                                  ? null
                                  : showKnockPlan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Knock',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(right: 40, left: 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 200,
                          child: Text(
                            widget.placeName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff7a7a7a),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: GestureDetector(
                            onTap: () => likePost(likeNumber, _likedPost),
                            behavior: HitTestBehavior.translucent,
                            child: Center(
                              child: Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      SizedBox(
                                        // margin: const EdgeInsets.only(top: 5),
                                        width: 60,
                                        height: 60,
                                        child: RiveAnimation.asset(
                                          _yourLikePostsData
                                                  .contains(widget.posts['id'])
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
                                            color: Color.fromARGB(
                                                255, 250, 250, 250),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 30),
                                    child: Text(
                                      likeNumber.toString(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Days
              Container(
                // TODO transparent the padding and change left's padding to 35
                padding: const EdgeInsets.only(top: 40, left: 25, right: 10),
                height: 100,
                color: Colors.transparent, // it doesn't work
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
                planList: plans[_selectedDayIndex],
                isDevelop: false,
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
