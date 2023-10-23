import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CustomCarouselSlider extends StatelessWidget {
  const CustomCarouselSlider({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO change to CarouselSlider.builder, after finish connecting to the database
    return CarouselSlider(
      items: [
        Card(
          margin: const EdgeInsets.only(right: 20, left: 20, bottom: 0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                Image.network(
                  'https://i.pinimg.com/564x/e5/7a/2a/e57a2a310330ee1d8928eb75d416a53d.jpg',
                  width: 500,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 180, right: 30, bottom: 30, left: 30),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 210,
                            height: 60,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: const Color(0xff757585),
                              ),
                            ),
                          ),
                          const Text(
                            'Fuji in 3 days',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      Container(
                        width: 50,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color(0xff4B4B5A),
                        ),
                        child: IconButton(
                          // TODO replace transition to the page of details
                          onPressed: () {
                            print('Hi fuji');
                          },
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
      options: CarouselOptions(
        height: 270,
        initialPage: 0,
        autoPlay: true,
        viewportFraction: 1,
        enableInfiniteScroll: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
      ),
    );
  }
}
