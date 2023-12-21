import 'package:flutter/material.dart';

// libraries immport
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// screens import
import '../../../profile/user_profile.dart';
import '../knock_plan_details.dart';
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
  final supabase = Supabase.instance.client;
  List _requestKnock = [];
  List _requestUserData = [];
  final List _yourLikePostsData = [];
  bool _isLoading = false;
  List _blockUsersList = [];

  void getBlockUsers() async {
    if (supabase.auth.currentUser != null) {
      final List blockUsers = await supabase
          .from('profiles')
          .select('block_users')
          .eq('id', supabase.auth.currentUser!.id);
      _blockUsersList = blockUsers[0]['block_users'];
    }
  }

  Future getKnockInfo() async {
    if (!mounted) return;
    _isLoading = true;
    final supabase = Supabase.instance.client;
    List requestUserData = [];
    List userData = [];

    final List requestKnock = await supabase
        .from('knock')
        .select('*')
        .eq('owner_id', supabase.auth.currentUser!.id)
        .order('is_completed', ascending: true);
    setState(() {
      // このコードを書くと、ユーザーがKnockが来ているのに表示されない、そしてもう一回リロードとかするとKnockがなくなる現象が起きてbugだと思うから統一
      // requestKnock.removeWhere((requestKnock) =>
      //     _blockUsersList.contains(requestKnock['request_user_id']));
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
      debugPrint('_yourLikePostsData$_yourLikePostsData');
    });
  }

  @override
  void initState() {
    super.initState();
    getBlockUsers();
    getKnockInfo();
    getLikePosts();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final knockedNumber = _requestKnock.length.toString();
    return _isLoading
        ? Center(
            child: Container(
              margin: const EdgeInsets.only(top: 100, bottom: 100),
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
            // userがknockした詳細のCards
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      left: width * 0.07,
                      top: height * 0.04,
                    ), // left: 40 top: 20
                    child: Text(
                      knockedNumber == '1'
                          ? 'Knocked to you $knockedNumber time'
                          : 'Knocked to you $knockedNumber times',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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
                        return _blockUsersList.contains(
                                _requestKnock[index]['request_user_id'])
                            ? const SizedBox()
                            : GestureDetector(
                                onTap: () {
                                  if (_requestKnock[index]['is_completed']) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return KnockPlanDetailsScreen(
                                            title: _requestKnock[index]
                                                ['title'],
                                            thumbnail: _requestKnock[index]
                                                ['thumbnail'],
                                            planDetailsList:
                                                _requestKnock[index]['plans'],
                                            requestedUserAvatar: _requestUserData[
                                                    index][0]['avatar_url'] ??
                                                "https://pmmgjywnzshfclavyeix.supabase.co/storage/v1/object/public/posts/30fe397b-74c1-4c5c-b037-a586917b3b42/grey-icon.jpg",
                                            requestedUserName:
                                                _requestUserData[index][0]
                                                        ['username'] ??
                                                    "hi",
                                            requestedUserId:
                                                _requestUserData[index][0]
                                                    ['id'],
                                            yourAvatar: widget.yourAvatar,
                                            yourName: widget.yourName,
                                            isYourKnock: false,
                                          );
                                        },
                                      ),
                                    );
                                    return;
                                  }
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return KnockDevelopScreen(
                                          title: _requestKnock[index]['title'],
                                          period: _requestKnock[index]
                                              ['period'],
                                          destination: _requestKnock[index]
                                              ['destination'],
                                          requestUserAvatar: _requestUserData[
                                                  index][0]['avatar_url'] ??
                                              "https://pmmgjywnzshfclavyeix.supabase.co/storage/v1/object/public/posts/30fe397b-74c1-4c5c-b037-a586917b3b42/grey-icon.jpg",
                                          requestUserName:
                                              _requestUserData[index][0]
                                                      ['username'] ??
                                                  "hi",
                                          knockId: _requestKnock[index]['id'],
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.all(width * 0.05), // 20
                                      margin:
                                          EdgeInsets.all(width * 0.05), // 20
                                      constraints: const BoxConstraints(
                                          minHeight: 100), // 100
                                      width: width, // 390
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
                                                    userId:
                                                        _requestUserData[index]
                                                            [0]['id'],
                                                    yourLikePostsData:
                                                        _yourLikePostsData,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width:
                                                  width >= 500 ? 90 : 70, // 70
                                              height: width >= 500 ? 90 : 70,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              clipBehavior:
                                                  Clip.antiAliasWithSaveLayer,
                                              child: CachedNetworkImage(
                                                imageUrl: _requestUserData[
                                                            index][0]
                                                        ['avatar_url'] ??
                                                    "https://pmmgjywnzshfclavyeix.supabase.co/storage/v1/object/public/posts/30fe397b-74c1-4c5c-b037-a586917b3b42/grey-icon.jpg",
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  _requestUserData[index][0]
                                                              ['username'] ==
                                                          null
                                                      ? 'From hi'
                                                      : 'From ' +
                                                          _requestUserData[
                                                                  index][0]
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
                                    // is_completed（そのplanが完成していたら）
                                    _requestKnock[index]['is_completed']
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
                                                right: width * 0.03), // 12
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            clipBehavior:
                                                Clip.antiAliasWithSaveLayer,
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
