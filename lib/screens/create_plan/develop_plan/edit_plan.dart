import 'package:flutter/material.dart';

// libraries import
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

// screens import
import 'package:travelknock/screens/create_plan/develop_plan/develop_plan.dart';
import '../../../components/custom_widgets/plans/custom_fab.dart';
import '../../login/login.dart';

// components import
import 'package:travelknock/components/custom_widgets/text_fields/custom_day_text_field.dart';
import 'package:travelknock/components/custom_widgets/text_fields/custom_text_field.dart';

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

    // width and height
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // day
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
        actions: const [],
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
      // clear button's location
      floatingActionButtonLocation: CustomizeFloatingLocation(
          FloatingActionButtonLocation.miniEndTop, 20, 0),
      floatingActionButtonAnimator: AnimationNoScaling(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: height >= 1000 ? height * 0.17 : height * 0.13,
                ),
                Padding(
                  padding: EdgeInsets.only(left: width * 0.06),
                  child: const Text(
                    'Edit Plan 🖊️',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: height >= 1000 ? height * 0.1 : height * 0.07, // 60
                ),
                Padding(
                  padding: EdgeInsets.only(left: width * 0.06),
                  child: CustomTextField(
                    title: 'Title',
                    labelText: 'e.g. Okinawa in 3 days',
                    controller: planTitleController,
                  ),
                ),
                SizedBox(
                  height: height * 0.07,
                ),
                Padding(
                  padding: EdgeInsets.only(left: width * 0.06),
                  child: CustomTextField(
                    title: 'Place',
                    labelText: 'e.g. Okinawa',
                    controller: placeNameController,
                  ),
                ),
                SizedBox(
                  height: height * 0.07,
                ),
                Padding(
                  padding: EdgeInsets.only(left: width * 0.06),
                  child: const Text(
                    'Period',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                Padding(
                  padding: EdgeInsets.only(left: width * 0.06),
                  child: CustomDayTextField(
                      controller: periodController, labelText: 'e.g. 3'),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: height * 0.07,
                      right: width * 0.2,
                      left: width * 0.2,
                      bottom: height * 0.08, // 50
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
                                backgroundColor:
                                    Color.fromARGB(255, 94, 94, 109),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
