
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/components/custom_text_field.dart';
import '../login.dart';
import 'dart:math';

class NewPlanScreen extends StatelessWidget {
  const NewPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final _planTitleController = TextEditingController();
    final _placeNameController = TextEditingController();
    final _periodController = TextEditingController();

    void signOut() async {
      await supabase.auth.signOut();

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }

    return Scaffold(
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 110,
              ),
              // logout button
              // IconButton(
              //   onPressed: signOut,
              //   icon: const Icon(
              //     Icons.exit_to_app,
              //     size: 40,
              //   ),
              // ),
              const Text(
                'New Plan 💡',
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
                controller: _planTitleController,
              ),
              const SizedBox(
                height: 60,
              ),
              CustomTextField(
                title: 'Place',
                labelText: 'e.g. Okinawa',
                controller: _placeNameController,
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
              SizedBox(
                width: 200,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'e.g. 3',
                    suffixIcon: const Padding(
                        padding: EdgeInsets.all(20), child: Text('days')),
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
                  controller: _periodController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 60, right: 50, left: 50, bottom: 50),
                child: SizedBox(
                  height: 70,
                  width: 200,
                  child: ElevatedButton(
                    // DONE create a transition to PlansScreen and add details to the database
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4B4B5A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        )),
                    child: const Text(
                      'Create a plan',
                      style: TextStyle(fontSize: 20),
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
