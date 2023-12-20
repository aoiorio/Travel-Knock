import 'package:flutter/material.dart';

// libraries import
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// screens import
import '../profile/user_profile.dart';

// component import
import '../../components/custom_widgets/text_fields/custom_day_text_field.dart';
import '../tabs.dart';

class KnockPlanScreen extends StatefulWidget {
  const KnockPlanScreen({
    super.key,
    required this.ownerAvatar,
    required this.ownerName,
    required this.requestUserId,
    required this.ownerId,
  });

  final String ownerAvatar;
  final String ownerName;
  final String requestUserId;
  final String ownerId;

  @override
  State<KnockPlanScreen> createState() => _KnockPlanScreenState();
}

class _KnockPlanScreenState extends State<KnockPlanScreen> {
  final supabase = Supabase.instance.client;

  // usersInfo
  String requestUserAvatar = '';
  String requestUserName = '';
  List _ownerPlaces = [];
  final List _yourLikePostsData = [];

  // dropButton
  List places = [];
  var _selectedPlace;

  bool _isLoading = false;

  final _periodController = TextEditingController();

  void getRequestUserInfo() async {
    final userData = await supabase
        .from('profiles')
        .select('*')
        .eq('id', widget.requestUserId)
        .single();
    setState(() {
      requestUserAvatar = userData['avatar_url'] ??
          "https://pmmgjywnzshfclavyeix.supabase.co/storage/v1/object/public/posts/30fe397b-74c1-4c5c-b037-a586917b3b42/grey-icon.jpg";
      requestUserName = userData['username'] ?? "hi";
    });
  }

  void getOwnerInfo() async {
    final ownerPlaces = await supabase
        .from('profiles')
        .select('places')
        .eq('id', widget.ownerId)
        .single();
    setState(() {
      _ownerPlaces = ownerPlaces['places'];
    });
  }

  void doKnock(String title) async {
    if (_periodController.text[0] == "0") {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    await supabase.from('knock').insert({
      'request_user_id': supabase.auth.currentUser!.id,
      'owner_id': widget.ownerId,
      'title': title,
      'destination': _selectedPlace,
      'period': _periodController.text,
    });
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    // print('knock!: $title');
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return const TabsScreen(initialPageIndex: 1);
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
      // print('_yourLikePostsData$_yourLikePostsData');
    });
  }

  @override
  void initState() {
    super.initState();
    getRequestUserInfo();
    getOwnerInfo();
    getLikePosts();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (_ownerPlaces.isEmpty) {
    } else {
      places = _ownerPlaces;
    }

    return GestureDetector(
      // キーボードをfocusしているときに他の所をタップするとキーボードを閉じる
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(20),
            // MediaQuery.of(context).size.height / 1.4
            height: height >= 1000
                ? height / 1.8
                : MediaQuery.of(context).size.height / 1.4,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 225, 225, 225),
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(
                      width: 15,
                      height: 15,
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                      ), // left: 15
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 110),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              requestUserName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 100,
                              height: 100,
                              decoration:
                                  const BoxDecoration(shape: BoxShape.circle),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: requestUserAvatar.isEmpty
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child:
                                          const ColoredBox(color: Colors.white),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserProfileScreen(
                                              userId:
                                                  supabase.auth.currentUser!.id,
                                              yourLikePostsData:
                                                  _yourLikePostsData,
                                            ),
                                          ),
                                        );
                                      },
                                      child: CachedNetworkImage(
                                        key: UniqueKey(),
                                        imageUrl: requestUserAvatar,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            const SizedBox(
                              height: 10, // 10
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 20,
                        right: MediaQuery.of(context).size.width / 10,
                        left: MediaQuery.of(context).size.width / 10,
                      ),
                      child: const Icon(
                        Icons.multiple_stop,
                        size: 40,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 110),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.ownerName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 100,
                              height: 100,
                              decoration:
                                  const BoxDecoration(shape: BoxShape.circle),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: requestUserAvatar.isEmpty
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child:
                                          const ColoredBox(color: Colors.white),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserProfileScreen(
                                              userId: widget.ownerId,
                                              yourLikePostsData:
                                                  _yourLikePostsData,
                                            ),
                                          ),
                                        );
                                      },
                                      child: CachedNetworkImage(
                                        key: UniqueKey(),
                                        imageUrl: widget.ownerAvatar,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: height * 0.025,
                        left: width * 0.06,
                        bottom: height * 0.025,
                      ), // top: 25, left: 25, bottom: 20
                      child: const Text(
                        'Destination',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: width * 0.06),
                      width: width * 0.8, // 300
                      decoration: BoxDecoration(
                        color: const Color(0xffEEEEEE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            value: _selectedPlace,
                            items: places
                                .map(
                                  (place) => DropdownMenuItem(
                                    value: place,
                                    child: Text(place),
                                  ),
                                )
                                .toList(),
                            hint: const Text(
                              'Choose a destination',
                              style: TextStyle(fontSize: 17),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _selectedPlace = value;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            focusColor: Colors.grey,
                            iconEnabledColor: Colors.black,
                            menuMaxHeight: height * 0.5, // 300
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: height * 0.025,
                        bottom: height * 0.025,
                        left: width * 0.06,
                      ), // top: 25, bottom: 20, left: 25
                      child: const Text(
                        'Period',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.06), // left: 25
                      child: CustomDayTextField(
                        controller: _periodController,
                        labelText: 'e.g. 3',
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: height * 0.05), // bottom: 20, top: 40
                  child: Center(
                    child: SizedBox(
                      height: 70,
                      width: 200,
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xff4B4B5A),
                              ),
                            )
                          : ElevatedButton(
                              // DONE implement knock feature!!
                              onPressed: () {
                                if (_selectedPlace == null ||
                                    _periodController.text.isEmpty) {
                                  return;
                                }
                                doKnock(_periodController.text == "1"
                                    ? '${'In ' + _selectedPlace} For a Day'
                                    : '${'In ' + _selectedPlace} For ${_periodController.text} Days');
                              },
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
