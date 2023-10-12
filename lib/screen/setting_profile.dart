import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/screen/add_places.dart';
import 'package:travelknock/screen/login.dart';

class SettingProfileScreen extends StatefulWidget {
  const SettingProfileScreen({super.key});

  @override
  State<SettingProfileScreen> createState() => _SettingProfileScreenState();
}

class _SettingProfileScreenState extends State<SettingProfileScreen> {
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final placeNameController = TextEditingController();

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
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            // padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            padding: const EdgeInsets.all(40),
            height: 300,
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Place',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                const SizedBox(
                  height: 40,
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: 'Place name',
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
                  controller: placeNameController,
                ),
                const SizedBox(
                  height: 40,
                ),
                Center(
                  child: SizedBox(
                    width: 100,
                    height: 50,
                    child: ElevatedButton(
                      // TODO add the place name to the setting_profile screen
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff4B4B5A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: const Text(
                        'Add',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void photoButtonClick() {
    print('Photo button clicked!!');
  }

  @override
  Widget build(BuildContext context) {
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
            Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 250,
                  height: 350,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xffEEEEEE),
                    ),
                  ),
                ),
                Center(
                  child: IconButton(
                    // TODO create the database with supabase and connect to strage
                    onPressed: photoButtonClick,
                    icon: const Icon(
                      Icons.wallpaper_outlined,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
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
                      controller: nameController,
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      const Text(
                        'Your Places',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 90,
                      ),
                      SizedBox(
                        width: 80,
                        height: 50,
                        child: ElevatedButton(
                          // TODO display the add places screen as showBottomSheet
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
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Center(
                    child: SizedBox(
                      height: 70,
                      width: 200,
                      child: ElevatedButton(
                        // TODO create a transition to PlansScreen and add details to the database
                        onPressed: () {},
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
