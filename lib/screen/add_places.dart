import 'package:flutter/material.dart';

class AddPlacesScreen extends StatelessWidget {
  const AddPlacesScreen({super.key, required this.placeNameController, required this.addPlace});

  final TextEditingController placeNameController;
  final Function(String) addPlace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
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
              maxLength: 20,
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
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                    // DONE add the place name to the setting_profile screen
                    onPressed: () {
                      if (placeNameController.text.trim().isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              title: const Text('Fill your place name'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    placeNameController.clear();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Got it',
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 68, 66, 66)),
                                  ),
                                )
                              ],
                            );
                          },
                        );
                        return;
                      }
                      addPlace(placeNameController.text.trim());
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4B4B5A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                    child: const Text(
                      'Add',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
