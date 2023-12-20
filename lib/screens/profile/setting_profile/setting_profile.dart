import 'dart:math';

import 'package:flutter/material.dart';

// library import
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/screens/plans/plans.dart';

// screens import
import 'package:travelknock/screens/profile/setting_profile/add_places.dart';
import 'package:travelknock/screens/tabs.dart';

// components import
import 'package:travelknock/components/profile/avatar.dart';
import 'package:travelknock/components/custom_widgets/text_fields/custom_text_field.dart';
import 'package:travelknock/components/profile/header.dart';

class SettingProfileScreen extends StatefulWidget {
  const SettingProfileScreen({super.key, required this.isEdit});

  final bool isEdit;

  @override
  State<SettingProfileScreen> createState() => _SettingProfileScreenState();
}

class _SettingProfileScreenState extends State<SettingProfileScreen> {
  final supabase = Supabase.instance.client;

  final _nameController = TextEditingController();
  final _placeNameController = TextEditingController();
  List<dynamic> userPlacesList = [];
  String? _imageUrl;
  String? _headerUrl;
  bool _isLoading = false;

  @override
  void dispose() {
    _placeNameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  Future<void> getUserInfo() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final data =
          await supabase.from('profiles').select().eq('id', userId).single();
      setState(() {
        _nameController.text = data['username'];
        userPlacesList = data['places'];
        _imageUrl = data['avatar_url'];
        _headerUrl = data['header_url'];
      });
    } on Exception {
      print('This user is new!');
    }
  }

  void showAddPlacesScreen() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          child: AddPlacesScreen(
              placeNameController: _placeNameController, addPlace: addPlace),
        );
      },
    );
  }

  void addPlace(String place) {
    // reset the value of textField
    _placeNameController.clear();
    // add place to the userPlacesList
    setState(() {
      userPlacesList.add(place);
    });
    Navigator.of(context).pop(_placeNameController.text);
    // print(userPlacesList);
  }

  // 4文字のランダムなuserNameを生成
  String generateUserName() {
    const length = 4;
    const String charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz';
    final Random random = Random.secure();
    final String randomStr =
        List.generate(length, (_) => charset[random.nextInt(charset.length)])
            .join();
    debugPrint(randomStr);
    return randomStr;
  }

  void updateProfile() async {
    final userId = supabase.auth.currentUser!.id;
    final username = _nameController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      await supabase.from('profiles').upsert({
        'id': userId,
        'updated_at': DateTime.timestamp().toIso8601String(),
        'username': username.isEmpty ? generateUserName() : username,
        'places': userPlacesList.isEmpty ? ["Travel island"] : userPlacesList,
        'is_setting_profile': true,
      });
      if (_imageUrl == null) {
        await supabase.from('profiles').update({
          'avatar_url':
              "https://pmmgjywnzshfclavyeix.supabase.co/storage/v1/object/public/posts/30fe397b-74c1-4c5c-b037-a586917b3b42/grey-icon.jpg"
        }).eq('id', userId);
      }

      debugPrint('Entered submit button!');
      if (!mounted) return;
      // DONE use Navigator.of(context).pushReplacement and transition to PlansScreen
      if (widget.isEdit) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) {
              return const TabsScreen(initialPageIndex: 1);
            },
          ),
          (route) {
            return false;
          },
        );
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return const TabsScreen(
              initialPageIndex: 0,
            );
          },
        ),
      );
    } catch (error) {
      debugPrint(error.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'The same name exists. Please change another one or try again.'),
          backgroundColor: Color.fromARGB(255, 94, 94, 109),
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // print(supabase.auth.currentUser!.id);
    return GestureDetector(
      // どこかをタップするとキーボードを閉じるコード
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          toolbarHeight: 30,
          automaticallyImplyLeading: widget.isEdit ? true : false,
        ),
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(
                    top: height * 0.1, left: width * 0.09), // 110, 25
                child: Column(
                  children: [
                    Text(
                      widget.isEdit ? 'Edit You 🐴' : 'About You 🦄',
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
              // display icon, and if user pushed the edit button from profileScreen, the header will appear.
              widget.isEdit
                  ? Container(
                      margin: const EdgeInsets.only(top: 30, bottom: 90),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        clipBehavior: Clip.none,
                        children: [
                          Header(
                            headerUrl: _headerUrl,
                            width: width * 0.84, // 330
                            height: width >= 500
                                ? height * 0.4
                                : height * 0.24, // 200
                            onUpload: (imageUrl) async {
                              setState(() {
                                _headerUrl = imageUrl;
                              });
                              final userId = supabase.auth.currentUser!.id;
                              await supabase.from('profiles').update(
                                  {'header_url': imageUrl}).eq('id', userId);
                            },
                          ),
                          Positioned(
                            bottom: -80,
                            child: Avatar(
                              imageUrl: _imageUrl,
                              width: 140,
                              height: 140,
                              onUpload: (imageUrl) async {
                                setState(() {
                                  _imageUrl = imageUrl;
                                  _imageUrl ??=
                                      "https://pmmgjywnzshfclavyeix.supabase.co/storage/v1/object/public/posts/30fe397b-74c1-4c5c-b037-a586917b3b42/grey-icon.jpg";
                                  // imageUrl =
                                  //     "https://pmmgjywnzshfclavyeix.supabase.co/storage/v1/object/public/posts/30fe397b-74c1-4c5c-b037-a586917b3b42/grey-icon.jpg";
                                });
                                final userId = supabase.auth.currentUser!.id;
                                await supabase.from('profiles').update(
                                    {'avatar_url': imageUrl}).eq('id', userId);
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : Avatar(
                      imageUrl: _imageUrl,
                      width: 250,
                      height: 350,
                      onUpload: (imageUrl) async {
                        setState(() {
                          print(imageUrl);
                          _imageUrl = imageUrl;
                          _imageUrl ??=
                              "https://pmmgjywnzshfclavyeix.supabase.co/storage/v1/object/public/posts/30fe397b-74c1-4c5c-b037-a586917b3b42/grey-icon.jpg";
                        });
                        final userId = supabase.auth.currentUser!.id;
                        await supabase
                            .from('profiles')
                            .update({'avatar_url': imageUrl}).eq('id', userId);
                      },
                    ),
              SizedBox(height: height * 0.03),

              // nameTextField
              Container(
                margin:
                    EdgeInsets.only(left: width * 0.09, right: width * 0.09),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      title: 'Name',
                      labelText: 'Your name',
                      controller: _nameController,
                    ),
                    SizedBox(
                      height: height * 0.05,
                    ),

                    // yourPlace text and add places button
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Your Places',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: width >= 500
                              ? width >= 1000
                                  ? 700
                                  : 400
                              : width * 0.25, // 90
                        ),
                        Expanded(
                          child: SizedBox(
                            // width: 80, // 80
                            height: height * 0.065, // 50
                            child: ElevatedButton(
                              // DONE display the add places screen as showBottomSheet
                              onPressed: showAddPlacesScreen,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff4B4B5A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // placesList
                    if (userPlacesList.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userPlacesList.length,
                        padding: const EdgeInsets.only(top: 30),
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(
                                  top: 10, bottom: 10, left: 20, right: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    userPlacesList[index],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  // delete icon button
                                  IconButton(
                                    alignment: Alignment.centerRight,
                                    onPressed: () {
                                      setState(() {
                                        userPlacesList.removeAt(index);
                                        // print(userPlacesList);
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Color.fromARGB(255, 148, 89, 85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    // show illustrations if the user doesn't have any places
                    userPlacesList.isEmpty
                        ? Center(
                            child: Container(
                              padding: EdgeInsets.only(bottom: height * 0.04),
                              // height: height * 0.1, // 50
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  // TODO change illustration
                                  Image.asset('assets/images/no-places.PNG'),
                                  const Text(
                                    'No Places',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(height: height * 0.03), // 10

                    // Submit Button
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xff4B4B5A),
                            ),
                          )
                        : Padding(
                            padding:
                                EdgeInsets.only(bottom: height * 0.05), // 30
                            child: Center(
                              child: SizedBox(
                                height: 70,
                                width: width * 0.5, // 200
                                child: ElevatedButton(
                                  // DONE create a transition to PlansScreen and add details to the database
                                  onPressed: () {
                                    final username =
                                        _nameController.text.trim();
                                    // confirm username, userPlacesList . if users didn't set their profile, there will be dialog.
                                    if (username.isEmpty ||
                                        userPlacesList.isEmpty ||
                                        _imageUrl == null) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            title: const Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Would you like to set avatar or name or places?",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xff4B4B5A)),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                              ],
                                            ),
                                            actionsAlignment:
                                                MainAxisAlignment.center,
                                            actions: [
                                              Container(
                                                width: 140,
                                                height: 50,
                                                margin: EdgeInsets.only(
                                                    bottom: height * 0.03),
                                                child: _isLoading
                                                    ? const Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          color:
                                                              Color(0xff4B4B5A),
                                                        ),
                                                      )
                                                    : ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              const Color(
                                                                  0xfff2f2f2),
                                                          foregroundColor:
                                                              Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'No thank you',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xff4B4B5A),
                                                          ),
                                                        ),
                                                        onPressed: () async {
                                                          setState(() {
                                                            _isLoading = true;
                                                          });
                                                          updateProfile();
                                                          setState(() {
                                                            _isLoading = false;
                                                          });
                                                          // go to PlansScreen
                                                          Navigator.of(context)
                                                              .pushAndRemoveUntil(
                                                                  MaterialPageRoute(
                                                            builder: (context) {
                                                              return const TabsScreen(
                                                                  initialPageIndex:
                                                                      0);
                                                            },
                                                          ), (route) => false);
                                                        },
                                                      ),
                                              ),
                                              SizedBox(width: width * 0.02),
                                              Container(
                                                width: 100,
                                                height: 50,
                                                margin: EdgeInsets.only(
                                                    bottom: height * 0.03),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xff4B4B5A),
                                                    foregroundColor:
                                                        Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                  ),
                                                  child: const Text('Set them'),
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      return;
                                    }

                                    // normal submit
                                    updateProfile();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff4B4B5A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    'Submit',
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
            ],
          ),
        ),
      ),
    );
  }
}
