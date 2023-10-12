import 'package:flutter/material.dart';

class AddPlacesScreen extends StatelessWidget {
  const AddPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        // padding: EdgeInsets.all(30),
        // decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(20)),
        // height: 500,
        // width: double.infinity,
        // alignment: Alignment.center,
        children: [
          Text(
            'Add Place',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ],
      ),
    );
  }
}
