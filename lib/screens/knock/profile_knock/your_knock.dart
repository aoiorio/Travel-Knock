import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../profile/user_profile.dart';
import 'knock_plan_details.dart';

class YourKnock extends StatefulWidget {
  const YourKnock({
    super.key,
    required this.yourAvatar,
    required this.yourName,
  });

  final String yourAvatar;
  final String yourName;

  @override
  State<YourKnock> createState() => _YourKnockState();
}

class _YourKnockState extends State<YourKnock> {
  final supabase = Supabase.instance.client;
  List _requestedKnock = [];
  List _userData = [];
  List _ownerData = [];
  final List _yourLikePostsData = [];
  bool _isLoading = false;

  void getRequestedKnockInfo() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    final userId = supabase.auth.currentUser!.id;
    List ownerData = [];
    final requestedUserData = await supabase
        .from('knock')
        .select('*')
        .eq('request_user_id', userId)
        .order('is_completed', ascending: true);
    setState(() {
      _requestedKnock = requestedUserData;
    });

    // get owner info
    for (var i = 0; ownerData.length < _requestedKnock.length; i++) {
      _userData = await supabase
          .from('profiles')
          .select('*')
          .eq('id', _requestedKnock[i]['owner_id']);
      setState(() {
        // print('users!! $_userData');
        ownerData.add(_userData);
      });
    }
    setState(() {
      _ownerData = ownerData;
      _isLoading = false;
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
    getRequestedKnockInfo();
    getLikePosts();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final yourKnockNumber = _requestedKnock.length.toString();
    return _isLoading
        ? Center(
            child: Container(
              margin: const EdgeInsets.only(top: 160),
              child: const CircularProgressIndicator(
                color: Color(0xff4B4B5A),
              ),
            ),
          )
        : _requestedKnock.isEmpty || _userData.isEmpty
            ? Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 200),
                  child: Column(
                    children: [
                      // DONE change a illustration.
                      Image.asset('assets/images/no-your-knock.PNG'),
                      const Text(
                        "You haven't knocked yet!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            // このuserにKnockされた詳細のCards
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      left: width * 0.07,
                      top: height * 0.04,
                    ),
                    child: Text(
                      yourKnockNumber == '1'
                          ? 'You have knocked $yourKnockNumber times'
                          : 'You have knocked $yourKnockNumber times',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 160),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _requestedKnock.length,
                      padding: const EdgeInsets.only(top: 10),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            if (_requestedKnock[index]['is_completed']) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return KnockPlanDetailsScreen(
                                      title: _requestedKnock[index]['title'],
                                      thumbnail: _requestedKnock[index]
                                          ['thumbnail'],
                                      planDetailsList: _requestedKnock[index]
                                          ['plans'],
                                      requestedUserAvatar: _ownerData[index][0]
                                          ['avatar_url'],
                                      requestedUserName: _ownerData[index][0]
                                          ['username'],
                                      requestedUserId: _ownerData[index][0]
                                          ['id'],
                                      yourAvatar: widget.yourAvatar,
                                      yourName: widget.yourName,
                                      isYourKnock: true,
                                    );
                                  },
                                ),
                              );
                              return;
                            }
                          },
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                padding: EdgeInsets.all(width * 0.05), // 20
                                margin: EdgeInsets.all(width * 0.05), // 20
                                constraints:
                                    const BoxConstraints(minHeight: 100),
                                width: width, // 390
                                // height: 100,
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
                                              userId: _ownerData[index][0]
                                                  ['id'],
                                              yourLikePostsData:
                                                  _yourLikePostsData,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: width >= 500 ? 90 : 70, // 70
                                        height: width >= 500 ? 90 : 70, // 70
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        child: CachedNetworkImage(
                                          imageUrl: _ownerData[index][0]
                                              ['avatar_url'],
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: width >= 500
                                          ? width * 0.13
                                          : width * 0.09, // 30
                                    ), // 40
                                    SizedBox(
                                      width: width * 0.5,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'To ' +
                                                _ownerData[index][0]
                                                    ['username'],
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            _requestedKnock[index]['title'],
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
                              _requestedKnock[index]['is_completed']
                                  ? Container(
                                      width: width * 0.3, // 115
                                      height: width >= 1000
                                          ? height * 0.06
                                          : height * 0.046, // 40
                                      margin: EdgeInsets.only(
                                        top: width >= 500
                                            ? width >= 1000
                                                ? height * 0.05
                                                : height * 0.02
                                            : 0,
                                        right: width * 0.03,
                                      ), // 12
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
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
