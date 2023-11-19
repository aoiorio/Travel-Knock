import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/components/custom_day_text_field.dart';
import 'package:travelknock/components/custom_text_field.dart';
import 'package:travelknock/screen/create_plan/develop_plan.dart';
import '../login.dart';
import 'dart:math';

class EditPlanScreen extends StatelessWidget {
  const EditPlanScreen({
    super.key,
    required this.planTitleText,
    required this.placeName,
    required this.period,
    required this.plans,
  });

  final String planTitleText;
  // planTitleController.text = planTitleText
  final String placeName;
  final String period;
  final List<List<Map<String, String>>> plans;

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final planTitleController = TextEditingController();
    final placeNameController = TextEditingController();
    final periodController = TextEditingController();

    // dainyuu
    planTitleController.text = planTitleText;
    placeNameController.text = placeName;
    periodController.text = period;

    void signOut() async {
      await supabase.auth.signOut();

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      extendBodyBehindAppBar: true,
      floatingActionButton: Transform.rotate(
        // 回転しちゃうぞ
        angle: -1 * pi / 180,
        child: Container(
          padding: const EdgeInsets.only(
            left: 300,
            // top: 60,
          ),
          child: SizedBox(
            width: 90,
            height: 90,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4B4B5A),
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(0),
                  ),
                ),
              ),
              child: const Icon(
                Icons.clear,
                size: 50,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 130,
                ),
                const Text(
                  'Edit Plan 🖊️',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 60,
                ),
                CustomTextField(
                  title: 'Title',
                  labelText: 'e.g. Okinawa in 3 days',
                  controller: planTitleController,
                ),
                const SizedBox(
                  height: 60,
                ),
                CustomTextField(
                  title: 'Place',
                  labelText: 'e.g. Okinawa',
                  controller: placeNameController,
                ),
                const SizedBox(
                  height: 60,
                ),
                const Text(
                  'Period',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomDayTextField(
                    controller: periodController, labelText: 'e.g. 3'),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 60,
                    right: 50,
                    left: 50,
                    bottom: 50,
                  ),
                  child: SizedBox(
                    height: 70,
                    width: 200,
                    child: ElevatedButton(
                      // DONE create a transition to PlansScreen and add details to the database
                      onPressed: () {
                        if (planTitleController.text.isEmpty ||
                            placeNameController.text.isEmpty ||
                            periodController.text.isEmpty ||
                            periodController.text[0] == '0') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Fill the title, place name and period',
                              ),
                              backgroundColor: Color.fromARGB(255, 94, 94, 109),
                            ),
                          );
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return DevelopPlanScreen(
                                title: planTitleController.text,
                                dayNumber: periodController.text,
                                placeName: placeNameController.text,
                                planList: plans,
                                isKnock: false,
                              );
                            },
                          ),
                        );
                      },
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
