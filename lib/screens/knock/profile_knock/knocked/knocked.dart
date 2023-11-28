import 'package:flutter/material.dart';

// libraries import
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// screens import
import 'package:travelknock/screens/knock/profile_knock/knock_plan_details.dart';
import 'package:travelknock/screens/profile/user_profile.dart';

import 'knock_develop.dart';

class KnockedScreen extends StatefulWidget {
  const KnockedScreen({
    super.key,
    required this.yourAvatar,
    required this.yourName,
  });

  final String yourAvatar;
  final String yourName;

  @override
  State<KnockedScreen> createState() => _KnockedScreenState();
}

class _KnockedScreenState extends State<KnockedScreen> {
  List _requestKnock = [];
  List _requestUserData = [];
  final List _yourLikePostsData = [];
  bool _isLoading = false;
  final supabase = Supabase.instance.client;

  Future getKnockInfo() async {
    if (!mounted) return;
    _isLoading = true;
    final supabase = Supabase.instance.client;
    List requestUserData = [];
    List userData = [];

    final requestKnock = await supabase
        .from('knock')
        .select('*')
        .eq('owner_id', supabase.auth.currentUser!.id)
        .order('is_completed', ascending: true);
    setState(() {
      _requestKnock = requestKnock;
    });

    if (_requestKnock.isEmpty) {
      _isLoading = false;
      return;
    }

    // userの情報をとる
    for (var i = 0; requestUserData.length < _requestKnock.length; i++) {
      userData = await supabase
          .from('profiles')
          .select('*')
          .eq('id', _requestKnock[i]['request_user_id']);
      setState(() {
        // print('users!! $_userData');
        requestUserData.add(userData);
      });
    }
    _isLoading = false;
    setState(() {
      _requestUserData = requestUserData;
    });
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
    getKnockInfo();
    getLikePosts();
  }

  @override
  Widget build(BuildContext context) {
    final knockedTime = _requestKnock.length.toString();
    return _isLoading
        ? Center(
            child: Container(
              margin: const EdgeInsets.only(top: 160),
              child: const CircularProgressIndicator(
                color: Color(0xff4B4B5A),
              ),
            ),
          )
        : _requestKnock.isEmpty || _requestUserData.isEmpty
            ? Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 200),
                  child: Column(
                    children: [
                      Image.asset('assets/images/no-knocked.PNG'),
                      const Text(
                        'No knocked yet!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 40, top: 20),
                    child: Text(
                      knockedTime == '1'
                          ? 'Knocked to you $knockedTime time'
                          : 'Knocked to you $knockedTime times',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 160),
                    child: ListView.builder(
                      shrinkWrap: true, //追加
                      physics: const NeverScrollableScrollPhysics(), //追加ƒ
                      itemCount: _requestKnock.length,
                      padding: const EdgeInsets.only(top: 10),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            if (_requestKnock[index]['is_completed']) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return KnockPlanDetailsScreen(
                                      title: _requestKnock[index]['title'],
                                      thumbnail: _requestKnock[index]
                                          ['thumbnail'],
                                      planDetailsList: _requestKnock[index]
                                          ['plans'],
                                      requestedUserAvatar:
                                          _requestUserData[index][0]
                                              ['avatar_url'],
                                      requestedUserName: _requestUserData[index]
                                          [0]['username'],
                                      requestedUserId: _requestUserData[index]
                                          [0]['id'],
                                      yourAvatar: widget.yourAvatar,
                                      yourName: widget.yourName,
                                      isYourKnock: false,
                                    );
                                  },
                                ),
                              );
                              return;
                            }
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) {
                                return KnockDevelopScreen(
                                  title: _requestKnock[index]['title'],
                                  period: _requestKnock[index]['period'],
                                  destination: _requestKnock[index]
                                      ['destination'],
                                  requestUserAvatar: _requestUserData[index][0]
                                      ['avatar_url'],
                                  requestUserName: _requestUserData[index][0]
                                      ['username'],
                                  knockId: _requestKnock[index]['id'],
                                );
                              },
                            ));
                          },
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                margin: const EdgeInsets.all(20),
                                constraints:
                                    const BoxConstraints(minHeight: 100),
                                width: 390,
                                decoration: BoxDecoration(
                                  color: const Color(0xffF2F2F2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserProfileScreen(
                                              userId: _requestUserData[index][0]
                                                  ['id'],
                                              // yourLikePostsData:
                                              //     _yourLikePostsData,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 70,
                                        height: 70,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        child: CachedNetworkImage(
                                          imageUrl: _requestUserData[index][0]
                                              ['avatar_url'],
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          20, // 30
                                    ), // 40
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'From ' +
                                                _requestUserData[index][0]
                                                    ['username'],
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            _requestKnock[index]['title'],
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _requestKnock[index]['is_completed']
                                  ? Container(
                                      width: 115,
                                      height: 40,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child: const Center(
                                        child: Text(
                                          'Completed',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
  }
}
