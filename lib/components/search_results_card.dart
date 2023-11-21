import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:rive/rive.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/screen/plans/plan_details.dart';

import '../screen/login.dart';

class SearchResultsCard extends StatefulWidget {
  const SearchResultsCard({
    super.key,
    required this.searchResult,
    required this.searchText,
  });

  final List searchResult;
  final String searchText;

  @override
  State<SearchResultsCard> createState() => _SearchResultsCardState();
}

class _SearchResultsCardState extends State<SearchResultsCard> {
  List _userAvatar = [];
  List _userName = [];
  final List _yourLikePostsData = [];
  final _likedPost = [];
  bool _ifSyntax(int index) {
    return (index + 1) % 2 == 0 && index != 0;
  }

  final supabase = Supabase.instance.client;

  void likePost(int index, int likeNumber, List likedPost) async {
    if (supabase.auth.currentUser == null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) {
          return const LoginScreen();
        },
      ));
      return;
    }
    final userId = supabase.auth.currentUser!.id;
    // print('Liked!!');
    List userList = widget.searchResult[index]['post_like_users'];
    final likes = await supabase
        .from('posts')
        .select('likes')
        .eq('id', widget.searchResult[index]['id'])
        .single();
    try {
      if (userList.contains(userId)) {
        userList.remove(userId);
        await supabase.from('posts').update({'likes': likes['likes'] - 1}).eq(
            'id', widget.searchResult[index]['id']);
        setState(() {
          likeNumber -= 1;
        });
      } else {
        userList.add(supabase.auth.currentUser!.id);
        await supabase.from('posts').update({'likes': likes['likes'] + 1}).eq(
            'id', widget.searchResult[index]['id']);
        setState(() {
          likeNumber++;
        });
      }
      await supabase.from('posts').update({'post_like_users': userList}).eq(
          'id', widget.searchResult[index]['id']);

      final likedPostId = await supabase
          .from('likes')
          .select('id')
          .eq('post_id', widget.searchResult[index]['id'])
          .eq('user_id', supabase.auth.currentUser!.id);
      setState(() {
        likedPost = likedPostId;
      });
      // 数字が変わるのと、アイコンの色が変わるのが別々で耐え難かったからこちらに移動=> これ動作しなかった

      // userがいいねをしていたらreturnする
      if (likedPost.isNotEmpty) {
        setState(() {
          _yourLikePostsData.remove(widget.searchResult[index]['id']);
        });
        await supabase.from('likes').delete().eq('id', likedPost[0]['id']);
        return;
      }
      setState(() {
        _yourLikePostsData.add(widget.searchResult[index]['id']);
      });
      await supabase.from('likes').insert({
        'user_id': supabase.auth.currentUser!.id,
        'post_id': widget.searchResult[index]['id'],
      });
    } catch (e) {
      print('error: $e');
    }
  }

  void getLikePosts() async {
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
    });
  }

  void getUserInfo() async {
    List userAvatarList = [];
    List userNameList = [];
    for (var i = 0; widget.searchResult.length > i; i++) {
      final userData = await supabase
          .from('profiles')
          .select('*')
          .eq('id', widget.searchResult[i]['user_id'])
          .single();
      setState(() {
        userAvatarList.add(userData['avatar_url']);
        userNameList.add(userData['username']);
      });
    }
    setState(() {
      _userAvatar = userAvatarList;
      _userName = userNameList;
      // print(_userAvatar);
    });
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
    getLikePosts();
  }

  @override
  Widget build(BuildContext context) {
    List searchLike(int index) {
      final searchLike = widget.searchResult[index]['post_like_users'];
      return searchLike;
    }

    return widget.searchResult.isEmpty
        ? Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              Image.asset('assets/images/no-knocked.PNG'),
              const Text(
                'No plans found!',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              )
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  widget.searchResult.length.toString() == '1'
                      ? '${widget.searchText} 🗝️ ${widget.searchResult.length} result'
                      : '${widget.searchText} 🗝️ ${widget.searchResult.length} results',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ListView.builder(
                itemCount: widget.searchResult.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 40),
                itemBuilder: (context, index) {
                  final likeNumber = searchLike(index).length;
                  return GestureDetector(
                    onTap: () {
                      if (_userAvatar.isEmpty || _userName.isEmpty) return;
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return PlanDetailsScreen(
                            title: widget.searchResult[index]['title'],
                            thumbnail: widget.searchResult[index]['thumbnail'],
                            planDetailsList: widget.searchResult[index]
                                ['plans'],
                            ownerId: widget.searchResult[index]['user_id'],
                            yourId: supabase.auth.currentUser!.id,
                          );
                        },
                      ));
                    },
                    child: Stack(
                      alignment: _ifSyntax(index)
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      children: [
                        Container(
                          constraints: const BoxConstraints(
                              minHeight: 250, minWidth: 50),
                          width: 300,
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(top: 20, bottom: 90),
                          decoration: BoxDecoration(
                            color: const Color(0xffF2F2F2),
                            borderRadius: BorderRadius.only(
                              topRight: _ifSyntax(index)
                                  ? const Radius.circular(0)
                                  : const Radius.circular(30),
                              topLeft: _ifSyntax(index)
                                  ? const Radius.circular(30)
                                  : const Radius.circular(0),
                              bottomRight: _ifSyntax(index)
                                  ? const Radius.circular(0)
                                  : const Radius.circular(30),
                              bottomLeft: _ifSyntax(index)
                                  ? const Radius.circular(30)
                                  : const Radius.circular(0),
                            ),
                          ),
                          alignment: Alignment.bottomLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Container(
                                  width: 200,
                                  margin: const EdgeInsets.only(top: 40),
                                  child: Text(
                                    widget.searchResult[index]['title'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    likePost(index, likeNumber, _likedPost),
                                child: Center(
                                  child: Row(
                                    children: [
                                      Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 5),
                                            width: 60,
                                            height: 60,
                                            child: RiveAnimation.asset(
                                              _yourLikePostsData.contains(
                                                      widget.searchResult[index]
                                                          ['id'])
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
                                                color: Color(0xffF2F2F2),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 40),
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
                            ],
                          ),
                        ),
                        Container(
                          width: 300,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: _ifSyntax(index)
                                    ? const Radius.circular(0)
                                    : const Radius.circular(30),
                                topLeft: _ifSyntax(index)
                                    ? const Radius.circular(30)
                                    : const Radius.circular(0),
                                bottomRight: _ifSyntax(index)
                                    ? const Radius.circular(0)
                                    : const Radius.circular(30),
                                bottomLeft: _ifSyntax(index)
                                    ? const Radius.circular(30)
                                    : const Radius.circular(0)),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: CachedNetworkImage(
                            imageUrl: widget.searchResult[index]['thumbnail'],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: _ifSyntax(index) ? 237 : 105,
                          top: 10,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: _userAvatar.isEmpty
                                ? Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 55,
                                      height: 55,
                                      decoration: const BoxDecoration(
                                          color: Colors.white),
                                    ),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: _userAvatar[index],
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Center(
                  child: Text(
                'Over!🍈',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ))
            ],
          );
  }
}
