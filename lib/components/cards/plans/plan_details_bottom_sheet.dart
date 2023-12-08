import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PlanDetailsBottomSheet extends StatelessWidget {
  const PlanDetailsBottomSheet({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.planTimeWidget,
  });

  final String title;
  final String imageUrl;
  final Widget planTimeWidget;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          padding: EdgeInsets.only(
            top: height * 0.02,
            left: width * 0.065,
            right: width * 0.065,
            bottom: height * 0.05,
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // center tenten
              Center(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 225, 225, 225),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 15,
                    height: 15,
                  ),
                ),
              ),
              Center(
                child: Column(
                  children: [
                    // plan_card image
                    Container(
                      margin: EdgeInsets.only(
                        top: height * 0.03,
                      ),
                      width: width * 0.9,
                      height: height * 0.25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.black,
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // plan_card planTimes
                    Padding(
                      padding: EdgeInsets.only(
                        top: height * 0.03,
                      ),
                      child: planTimeWidget,
                    ),

                    // plan_card title
                    SizedBox(
                      width: width, //350
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: height * 0.03,
                        ),
                        child: Text(
                          title,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
