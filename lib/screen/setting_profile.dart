import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/components/avatar.dart';
import 'package:travelknock/components/custom_text_field.dart';
import 'package:travelknock/components/header.dart';
import 'package:travelknock/screen/add_places.dart';
import 'package:travelknock/screen/tabs.dart';

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
        return AddPlacesScreen(
            placeNameController: _placeNameController, addPlace: addPlace);
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
    print(userPlacesList);
  }

  void updateProfile() async {
    setState(() {
      _isLoading = true;
    });
    final userId = supabase.auth.currentUser!.id;
    final username = _nameController.text.trim();

    // confirm username, userPlacesList and username's length
    if (username.isEmpty ||
        userPlacesList.isEmpty ||
        username.length <= 2 ||
        _imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Write your name at least 3 letters and add place and fill your icon.'),
          backgroundColor: Color.fromARGB(255, 94, 94, 109),
        ),
      );
      return;
    }

    try {
      await supabase.from('profiles').upsert({
        'id': userId,
        'updated_at': DateTime.timestamp().toIso8601String(),
        'username': username,
        'places': userPlacesList,
        'is_setting_profile': true,
      });
      print('Entered submit button!');
      // DONE use Navigator.of(context).pushReplacement and transition to PlansScreen
      if (widget.isEdit) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return const TabsScreen(initialPageIndex: 1);
            },
          ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The same name exists. Please change another one.'),
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
    print(supabase.auth.currentUser!.id);
    return Scaffold(
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
              margin: const EdgeInsets.only(top: 110, left: 25),
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
            widget.isEdit
                ? Container(
                    margin: const EdgeInsets.only(top: 30, bottom: 90),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      clipBehavior: Clip.none,
                      children: [
                        Header(
                          headerUrl: _headerUrl,
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
                        _imageUrl = imageUrl;
                      });
                      final userId = supabase.auth.currentUser!.id;
                      await supabase
                          .from('profiles')
                          .update({'avatar_url': imageUrl}).eq('id', userId);
                    },
                  ),
            Container(
              margin: const EdgeInsets.only(left: 50, right: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    title: 'Name',
                    labelText: 'Your name',
                    controller: _nameController,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Your Places',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 90,
                        height: 0,
                      ),
                      Expanded(
                        child: SizedBox(
                          width: 80,
                          height: 50, // 50
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      print(userPlacesList);
                                    });
                                  },
                                  icon: const Icon(Icons.delete,
                                      color: Color.fromARGB(255, 148, 89, 85)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  userPlacesList.isEmpty
                      ? const SizedBox(
                          height: 50,
                        )
                      : const SizedBox(
                          height: 10,
                        ),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xff4B4B5A),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: Center(
                            child: SizedBox(
                              height: 70,
                              width: 200,
                              child: ElevatedButton(
                                // DONE create a transition to PlansScreen and add details to the database
                                onPressed: updateProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff4B4B5A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(fontSize: 20),
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
    );
  }
}
