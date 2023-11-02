import 'dart:convert';

import 'package:flutter/material.dart';

class PlanDetailsScreen extends StatefulWidget {
  const PlanDetailsScreen({
    super.key,
    required this.title,
    required this.thumbnail,
    required this.planDetailsList,
  });

  final String title;
  final String thumbnail;
  final List planDetailsList;

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  var _selectedDayIndex = 0;
  var _isSelected = [true, false];
  List<List<Map<String, dynamic>>> plans = [];

  @override
  void initState() {
    super.initState();
    // 最初に選択されているDayは1日目というのを設定している
    _isSelected = List.generate(widget.planDetailsList.length, (index) {
      if (index == 0) {
        return true;
      }
      return false;
    });
    plans = convertStringToMap(widget.planDetailsList);
  }

  List<List<Map<String, dynamic>>> convertStringToMap(List<dynamic> planDetailsList) {
    final index = planDetailsList.length;
    List<List<Map<String, dynamic>>> dayPlans = List.generate(index, (index) => []);

    for (var i = 0; index > i; i++) {
      List dayPlanList = planDetailsList[i];
      var stringCount = dayPlanList.length;
      for (var j = 0; stringCount > j; j++) {
        String imitationMap = dayPlanList[j];
        dynamic decodedMap = json.decode(imitationMap);
        dayPlans[i].add(decodedMap);
      }
    }
    return dayPlans;
  }

  @override
  Widget build(BuildContext context) {
    // Databaseからとるのが、string型になっている
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 140, right: 25, left: 25, bottom: 25),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 37,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: 360,
              height: 300,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Image.network(
                widget.thumbnail,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            // Days
            Container(
              padding: const EdgeInsets.only(top: 40, left: 15, right: 10),
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ToggleButtons(
                    direction: Axis.horizontal,
                    isSelected: _isSelected,
                    onPressed: (int index) {
                      // The button that is tapped is set to true, and the others to false.
                      setState(() {
                        for (int i = 0; i < _isSelected.length; i++) {
                          _isSelected[i] = i == index;
                        }
                        _selectedDayIndex = index;
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    selectedBorderColor: const Color(0xff4B4B5A),
                    selectedColor: Colors.white,
                    fillColor: const Color(0xff4B4B5A),
                    color: const Color(0xff4B4B5A),
                    focusColor: const Color(0xff4B4B5A),
                    hoverColor: const Color(0xff4B4B5A),
                    splashColor: const Color.fromARGB(255, 104, 104, 115),
                    constraints: const BoxConstraints(
                      minHeight: 80.0,
                      minWidth: 120.0,
                    ),
                    children: List.generate(
                      widget.planDetailsList.length,
                      (index) => Text(
                        '${index + 1} Day',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 50),
              itemCount: plans[_selectedDayIndex].length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.bottomCenter, // topRightでもいい
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 290,
                          height: 210,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Card(
                            child: Image.network(
                              plans[_selectedDayIndex][index]['imageUrl']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 150,
                          child: Container(
                            constraints: const BoxConstraints(
                              minHeight: 90,
                            ),
                            width: 310,
                            decoration: BoxDecoration(
                              color: const Color(0xffEEEEEE),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 20.0,
                                  offset: Offset(10, 5),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 20, bottom: 7),
                                  child: Row(
                                    children: [
                                      Text(
                                        plans[_selectedDayIndex][index]['startTime']!,
                                        style: const TextStyle(
                                          color: Color(0xff797979),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Text(
                                        '-',
                                        style: TextStyle(
                                          color: Color(0xff797979),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        plans[_selectedDayIndex][index]['endTime']!,
                                        style: const TextStyle(
                                          color: Color(0xff797979),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, bottom: 20, right: 10),
                                    child: Text(
                                      plans[_selectedDayIndex][index]['title']!,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
