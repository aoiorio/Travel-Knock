import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/components/custom_clipper.dart';

import 'dart:convert';

import 'package:travelknock/components/plan_details_card.dart';
import 'package:travelknock/screen/knock/knock_plan.dart';
import 'package:travelknock/screen/login.dart';
import 'package:travelknock/screen/user_profile.dart';

class PlanDetailsScreen extends StatefulWidget {
  const PlanDetailsScreen({
    super.key,
    required this.title,
    required this.thumbnail,
    required this.planDetailsList,
    this.yourId,
    required this.ownerId,
  });

  final String title;
  final String thumbnail;
  final List planDetailsList;
  final String? yourId;
  final String ownerId;

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  var _selectedDayIndex = 0;
  var _isSelected = [true, false];
  List<List<Map<String, dynamic>>> plans = [];
  var heroTag = '';
  String _ownerAvatar = '';
  String _ownerName = '';
  final String _ownerId = '';
  final supabase = Supabase.instance.client;

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
                                          userId: widget.ownerId);
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
                            ? SizedBox(
                                width: 60,
                                child: Text(
                                  _ownerName,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
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
