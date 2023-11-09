import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/screen/knock/knock_plan_details.dart';

import 'knock_develop.dart';

class KnockedScreen extends StatefulWidget {
  const KnockedScreen({
    super.key,
  });

  @override
  State<KnockedScreen> createState() => _KnockedScreenState();
}

class _KnockedScreenState extends State<KnockedScreen> {
  List _requestKnock = [];
  List _requestUserData = [];
  List _userData = [];
  bool _isLoading = false;
  String _yourAvatar = '';
  String _yourName = '';

  Future getKnockInfo() async {
    if (!mounted) return;
    _isLoading = true;
    final supabase = Supabase.instance.client;
    List requestUserData = [];
    Map yourData = {};

    final requestKnock = await supabase
        .from('knock')
        .select('*')
        .eq('owner_id', supabase.auth.currentUser!.id);
    // print(_requestKnock);
    setState(() {
      _requestKnock = requestKnock;
    });

    if (_requestKnock.isEmpty) {
      _isLoading = false;
      return;
    }

    // userの情報をとる
    for (var i = 0; requestUserData.length < _requestKnock.length; i++) {
      _userData = await supabase
          .from('profiles')
          .select('*')
          .eq('id', _requestKnock[i]['request_user_id']);
      setState(() {
        // print('users!! $_userData');
        requestUserData.add(_userData);
      });
    }
    _isLoading = false;
    setState(() {
      _requestUserData = requestUserData;
    });

    yourData = await supabase
        .from('profiles')
        .select('*')
        .eq('id', supabase.auth.currentUser!.id)
        .single();

    setState(() {
      _yourAvatar = yourData['avatar_url'];
      _yourName = yourData['username'];
    });
  }

  @override
  void initState() {
    super.initState();
    getKnockInfo();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(100),
              child: CircularProgressIndicator(
                color: Color(0xff4B4B5A),
              ),
            ),
          )
        : _requestKnock.isEmpty || _requestUserData.isEmpty
            ? Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 100),
                  child: const Text(
                    'No knock yet!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true, //追加
                physics: const NeverScrollableScrollPhysics(), //追加ƒ
                itemCount: _requestKnock.length,
                padding: const EdgeInsets.only(top: 20),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (_requestKnock[index]['is_completed']) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return KnockPlanDetailsScreen(
                                title: _requestKnock[index]['title'],
                                thumbnail: _requestKnock[index]['thumbnail'],
                                planDetailsList: _requestKnock[index]['plans'],
                                requestedUserAvatar: _requestUserData[index][0]
                                    ['avatar_url'],
                                requestedUserName: _requestUserData[index][0]
                                    ['username'],
                                ownerAvatar: _yourAvatar,
                                ownerName: _yourName,
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
                            destination: _requestKnock[index]['destination'],
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
                          width: 390,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xffF2F2F2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: CachedNetworkImage(
                                  imageUrl: _requestUserData[index][0]
                                      ['avatar_url'],
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 30,
                              ), // 40
                              Column(
                                children: [
                                  Text(
                                    'From ' +
                                        _requestUserData[index][0]['username'],
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                            ],
                          ),
                        ),
                        _requestKnock[index]['is_completed']
                            ? Container(
                                width: 130,
                                height: 40,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(20)),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: const Center(
                                  child: Text(
                                    'Completed',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
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
              );
  }
}
