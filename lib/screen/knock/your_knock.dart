import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../plans/plan_details.dart';

class YourKnock extends StatefulWidget {
  const YourKnock({super.key});

  @override
  State<YourKnock> createState() => _YourKnockState();
}

class _YourKnockState extends State<YourKnock> {
  final supabase = Supabase.instance.client;
  List _requestedKnock = [];
  List _userData = [];
  List _ownerData = [];

  void getRequestedKnockInfo() async {
    if (!mounted) return;
    final userId = supabase.auth.currentUser!.id;
    List ownerData = [];
    final requestedUserData =
        await supabase.from('knock').select('*').eq('request_user_id', userId);
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
    });
  }

  @override
  void initState() {
    super.initState();
    getRequestedKnockInfo();
  }

  @override
  Widget build(BuildContext context) {
    return _requestedKnock.isEmpty || _ownerData.isEmpty
        ? Center(
            child: Container(
              margin: const EdgeInsets.all(100),
              child: const CircularProgressIndicator(
                color: Color(0xff4B4B5A),
              ),
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _requestedKnock.length,
            padding: const EdgeInsets.only(top: 20),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (_requestedKnock[index]['is_completed']) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return PlanDetailsScreen(
                            title: _requestedKnock[index]['title'],
                            thumbnail: _requestedKnock[index]['thumbnail'],
                            planDetailsList: _requestedKnock[index]['plans'],
                            userAvatar:
                                'https://pmmgjywnzshfclavyeix.supabase.co/storage/v1/object/public/posts//f94657a4-006b-4277-beeb-c1c52afae2f4/lYl4nq_3jlXFlqoa57wXCQ==?t=2023-11-09T16%3A31%3A55.795481',
                            userName: 'userName',
                            ownerId: 'f94657a4-006b-4277-beeb-c1c52afae2f4',
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
                              imageUrl: _ownerData[index][0]['avatar_url'],
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
                                'To ' + _ownerData[index][0]['username'],
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
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
                        ],
                      ),
                    ),
                    _requestedKnock[index]['is_completed']
                        ? Container(
                            width: 130,
                            height: 40,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20)),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: const Center(
                              child: Text('completed',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600)),
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
