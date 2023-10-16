import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/components/avatar.dart';
import 'package:travelknock/screen/add_places.dart';
import 'package:travelknock/screen/login.dart';

class SettingProfileScreen extends StatefulWidget {
  const SettingProfileScreen({super.key});

  @override
  State<SettingProfileScreen> createState() => _SettingProfileScreenState();
}

class _SettingProfileScreenState extends State<SettingProfileScreen> {
  final supabase = Supabase.instance.client;

  final _nameController = TextEditingController();
  final _placeNameController = TextEditingController();
  List<String> userPlacesList = [];
  String? _imageUrl;

  @override
  void dispose() {
    _placeNameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void signOut() async {
    await supabase.auth.signOut();

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
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

  void photoButtonClick() {
    print(supabase.auth.currentUser!.id);
  }

  void updateProfile() async {
    final userId = supabase.auth.currentUser!.id;
    final username = _nameController.text.trim();

    // confirm username, userPlacesList and username's length
    if (username.isEmpty || userPlacesList.isEmpty || username.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Write your name at least 3 letters and add place'),
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
      // TODO use Navigator.of(context).pushReplacement and transition to PlansScreen
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The same name exists. Please change another one.'),
          backgroundColor: Color.fromARGB(255, 94, 94, 109),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(supabase.auth.currentUser!.id);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 90, left: 25),
              child: const Column(
                children: [
                  Text(
                    'About you 🦄',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
            Avatar(
                imageUrl: _imageUrl,
                onUpload: (imageUrl) async {
                  setState(() {
                    _imageUrl = imageUrl;
                  });
                  final userId = supabase.auth.currentUser!.id;
                  await supabase
                      .from('profiles')
                      .update({'avatar_url': imageUrl}).eq('id', userId);
                }),
            Container(
              margin: const EdgeInsets.only(left: 50, right: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Name',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      decoration: InputDecoration(
                          labelText: 'Your name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          fillColor: const Color(0xffEEEEEE),
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never),
                      controller: _nameController,
                    ),
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
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10, bottom: 10, left: 20, right: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  userPlacesList[index],
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
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
                  Padding(
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
                              )),
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
