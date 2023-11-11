import 'package:flutter/material.dart';

// About pub
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

// About files
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/components/custom_day_text_field.dart';
import 'package:travelknock/screen/tabs.dart';

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
      requestUserAvatar = userData['avatar_url'];
      requestUserName = userData['username'];
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

  @override
  void initState() {
    super.initState();
    getRequestUserInfo();
    getOwnerInfo();
  }

  @override
  Widget build(BuildContext context) {
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
            height: MediaQuery.of(context).size.height / 1.4,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 225, 225, 225),
                        shape: BoxShape.circle),
                    child: const SizedBox(
                      width: 15,
                      height: 15,
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 15),
                      child: Column(
                        children: [
                          Text(
                            requestUserName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
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
                                : CachedNetworkImage(
                                    key: UniqueKey(),
                                    imageUrl: requestUserAvatar,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 20,
                          right: MediaQuery.of(context).size.width / 10,
                          left: MediaQuery.of(context).size.width / 10),
                      child: const Icon(
                        Icons.multiple_stop,
                        size: 40,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.ownerName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
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
                                : CachedNetworkImage(
                                    key: UniqueKey(),
                                    imageUrl: widget.ownerAvatar,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 25, left: 25, bottom: 20),
                  child: Text(
                    'Destination',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 300,
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
                          menuMaxHeight: 300,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 25, bottom: 20, left: 25),
                  child: Text(
                    'Period',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: CustomDayTextField(
                    controller: _periodController,
                    labelText: 'e.g. 3',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 40),
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
                              // TODO implement knock feature!!
                              onPressed: () {
                                if (_selectedPlace == null ||
                                    _periodController.text.isEmpty) {
                                  return;
                                }
                                doKnock(_periodController.text == 1
                                    ? '${'To ' + _selectedPlace} For a Day'
                                    : '${'To ' + _selectedPlace} For ${_periodController.text} Days');
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
