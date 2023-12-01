import 'package:flutter/material.dart';

// libraries import
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// screens import
import '../knock/knock_plan.dart';
import '../login/login.dart';

// component import
import '../../components/cards/plans/plan_card.dart';
import '../tabs.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen(
      {super.key, required this.userId, required this.yourLikePostsData});

  final String userId;
  final List yourLikePostsData;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final supabase = Supabase.instance.client;
  String _userAvatar = '';
  String _userHeader =
      'https://pmmgjywnzshfclavyeix.supabase.co/storage/v1/object/public/posts/6ab44cec-df53-4cc3-8c09-85907eb37815/IMG_8796.jpg';
  String _userName = '';
  List _userPlacesList = [];
  int? _knockedToUserCount;
  int? _userKnockedCount;
  List _userPostsList = [];
  bool _isLoading = false;
  List _yourLikePostsData = [];

  void goBackToLoginScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return const LoginScreen();
      },
    ));
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

  void likePost(int index, int likeNumber, List likedPost) async {
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
    if (userId == _userPostsList[index]['user_id']) {
      return;
    }

    List userList = _userPostsList[index]['post_like_users'];
    final likes = await supabase
        .from('posts')
        .select('likes')
        .eq('id', _userPostsList[index]['id'])
        .single();

    try {
      if (userList.contains(userId)) {
        userList.remove(userId);
        await supabase.from('posts').update({'likes': likes['likes'] - 1}).eq(
            'id', _userPostsList[index]['id']);
        setState(() {
          likeNumber -= 1;
        });
      } else {
        userList.add(userId);
        await supabase.from('posts').update({'likes': likes['likes'] + 1}).eq(
            'id', _userPostsList[index]['id']);
        setState(() {
          likeNumber++;
        });
      }
      await supabase.from('posts').update({'post_like_users': userList}).eq(
          'id', _userPostsList[index]['id']);

      final aLikedPost = await supabase
          .from('likes')
          .select('id')
          .eq('post_id', _userPostsList[index]['id'])
          .eq('user_id', supabase.auth.currentUser!.id);
      setState(() {
        likedPost = aLikedPost;
      });
      // 数字が変わるのと、アイコンの色が変わるのが別々で耐え難かったからこちらに移動 => いや、機能しないやん

      // userがその投稿にいいねをしていたらreturnする
      if (likedPost.isNotEmpty) {
        setState(() {
          _yourLikePostsData.remove(_userPostsList[index]['id']);
        });
        await supabase.from('likes').delete().eq('id', likedPost[0]['id']);
        return;
      }
      setState(() {
        _yourLikePostsData.add(_userPostsList[index]['id']);
      });
      await supabase.from('likes').insert({
        'user_id': supabase.auth.currentUser!.id,
        'post_id': _userPostsList[index]['id'],
      });
    } catch (e) {
      print('error: $e');
    }
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
          ownerAvatar: _userAvatar,
          ownerName: _userName,
          requestUserId: supabase.auth.currentUser!.id,
          ownerId: widget.userId,
        );
      },
    );
  }

  void showPostKnockPlan(int index) {
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
          ownerAvatar: _userAvatar,
          ownerName: _userName,
          requestUserId: supabase.auth.currentUser!.id,
          ownerId: _userPostsList[index]['user_id'],
        );
      },
    );
  }

  Future getPostUserInfo(int index) async {
    if (!mounted) return;
    final userAvatar = await supabase
        .from('profiles')
        .select('avatar_url')
        .eq('id', _userPostsList[index]['user_id'])
        .single();
    setState(() {
      _userAvatar = userAvatar['avatar_url'];
    });
    final userName = await supabase
        .from('profiles')
        .select('username')
        .eq('id', _userPostsList[index]['user_id'])
        .single();
    setState(() {
      _userName = userName['username'];
    });
  }

  void getUserInfo() async {
    setState(() {
      _isLoading = true;
    });
    final userData = await supabase
        .from('profiles')
        .select('*')
        .eq('id', widget.userId)
        .single();
    setState(
      () {
        _userAvatar = userData['avatar_url'];
        _userName = userData['username'];
        _userPlacesList = userData['places'];
        _isLoading = false;
        if (userData['header_url'] == null) return;
        _userHeader = userData['header_url'];
      },
    );
  }

  void getUserKnockInfo() async {
    final List knockedToUserData =
        await supabase.from('knock').select('*').eq('owner_id', widget.userId);
    final List userKnockedData = await supabase
        .from('knock')
        .select('*')
        .eq('request_user_id', widget.userId);

    setState(() {
      _knockedToUserCount = knockedToUserData.length;
      _userKnockedCount = userKnockedData.length;
    });
  }

  void getUserPosts() async {
    final userPostsData = await supabase
        .from('posts')
        .select('*')
        .eq('user_id', widget.userId)
        .order('likes', ascending: false);
    setState(() {
      _userPostsList = userPostsData;
    });
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
  void initState() {
    super.initState();
    // getLikePosts();
    _yourLikePostsData = widget.yourLikePostsData;
    getUserInfo();
    getUserKnockInfo();
    getUserPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: supabase.auth.currentUser == null
            ? null
            : widget.userId == supabase.auth.currentUser!.id
                ? null
                : [
                    // DONE create report features
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        onPressed: _openReportForm,
                        icon: const Icon(
                          Icons.warning_amber_outlined,
                          size: 30,
                        ),
                      ),
                    )
                  ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Transform.scale(
                  scale: 1.4,
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 3,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(160),
                        bottomLeft: Radius.circular(160),
                      ),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: _isLoading
                        ? Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.white),
                          )
                        : CachedNetworkImage(
                            imageUrl: _userHeader,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                  ),
                ),
                Positioned(
                  top: 230,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: _isLoading
                        ? Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              color: Colors.white,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: _userAvatar,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Center(
                child: _isLoading
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 140,
                          height: 30,
                          color: Colors.white,
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.only(right: 30, left: 30),
                        child: Text(
                          _userName,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: 145,
                height: 55,
                child: _isLoading
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: supabase.auth.currentUser == null
                            ? goBackToLoginScreen
                            : supabase.auth.currentUser!.id == widget.userId
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
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 35, left: 35, bottom: 20, right: 10),
              child: _isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.white,
                        width: 110,
                        height: 30,
                      ),
                    )
                  : Text(
                      "$_userName's Places",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            _isLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      margin: const EdgeInsets.only(left: 35),
                      width: 100,
                      height: 20,
                      color: Colors.white,
                    ),
                  )
                : Container(
                    height: 50,
                    width: 350,
                    padding: const EdgeInsets.only(left: 35),
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: _userPlacesList.length,
                      itemBuilder: (context, index) {
                        return Text(
                          index == (_userPlacesList.length - 1)
                              ? _userPlacesList[index]
                              : _userPlacesList[index] + ', ',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xff7A7a7A),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                constraints: const BoxConstraints(minHeight: 160),
                width: 320,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: _knockedToUserCount == null
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 50,
                          height: 20,
                          color: Colors.white,
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            // width: 280,
                            child: Text(
                              'Knocked to $_userName',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Text(
                            _knockedToUserCount.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            child: Text(
                              _knockedToUserCount == 1 ||
                                      _knockedToUserCount == 0
                                  ? 'time'
                                  : 'times',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: Container(
                constraints: const BoxConstraints(minHeight: 160),
                width: 320,
                decoration: BoxDecoration(
                  color: const Color(0xfff2f2f2),
                  borderRadius: BorderRadius.circular(30),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: _userKnockedCount == null
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 50,
                          height: 20,
                          color: Colors.white,
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              '$_userName knocked',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Text(
                            _userKnockedCount.toString(),
                            style: const TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            child: Text(
                              _userKnockedCount == 1 || _userKnockedCount == 0
                                  ? 'time'
                                  : 'times',
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
            Padding(
              padding: const EdgeInsets.only(top: 60, left: 40, right: 30),
              child: Text(
                "$_userName's Plans 🏖️",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            PlanCard(
              posts: _userPostsList,
              likePost: likePost,
              yourLikePostsData: _yourLikePostsData,
              showKnockPlan: showPostKnockPlan,
              getUserInfo: getPostUserInfo,
              listViewTopPadding: 30,
            ),
          ],
        ),
      ),
    );
  }
}
