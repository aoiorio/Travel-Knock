import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.title,
    required this.labelText,
    required this.controller,
  });

  final TextEditingController controller;
  final String title;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          width: width * 0.9, // 300
          child: TextField(
            decoration: InputDecoration(
              labelText: labelText,
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
            cursorColor: const Color(0xff4B4B5A),
          ),
        ),
      ],
    );
  }
}
