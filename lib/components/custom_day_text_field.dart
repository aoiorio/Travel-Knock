import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomDayTextField extends StatelessWidget {
  const CustomDayTextField(
      {super.key, required this.controller, required this.labelText});

  final TextEditingController controller;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 200,
        child: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: labelText,
            suffixIcon: const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'days',
                style: TextStyle(fontSize: 17),
              ),
            ),
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
          controller: controller,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
    );
  }
}
