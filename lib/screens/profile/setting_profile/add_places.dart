import 'package:flutter/material.dart';

class AddPlacesScreen extends StatelessWidget {
  const AddPlacesScreen({
    super.key,
    required this.placeNameController,
    required this.addPlace,
  });

  final TextEditingController placeNameController;
  final Function(String) addPlace;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          padding: EdgeInsets.only(
              top: 40, right: 40, left: 40, bottom: height * 0.02),
          height: height / 3,
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Place',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              SizedBox(
                height: height * 0.04, //40
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
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
                controller: placeNameController,
                cursorColor: const Color(0xff4B4B5A),
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: width * 0.3, // 100
                    height: height * 0.06, // 50
                    child: ElevatedButton(
                      // DONE add the place name to the setting_profile screen
                      onPressed: () {
                        if (placeNameController.text.trim().isEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                surfaceTintColor: const Color(0xff4B4B5A),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                title: const Text(
                                  'Please fill your place name',
                                  style: TextStyle(color: Color(0xff4B4B5A)),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      placeNameController.clear();
                                      Navigator.of(context).pop();
                                    },
                                    // splash colorを変える（ボタンを押した時の色）
                                    style: ButtonStyle(
                                      overlayColor: MaterialStateProperty.all(
                                        const Color(0xfff2f2f2),
                                      ),
                                    ),
                                    child: const Text(
                                      'Got it',
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 68, 66, 66)),
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
                        style: TextStyle(
                          fontSize: 16,
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
    );
  }
}
