import 'dart:io';

import 'package:flutter/material.dart';
import 'package:travelknock/screen/create_plan/add_plan.dart';

class DevelopPlanScreen extends StatefulWidget {
  const DevelopPlanScreen(
      {super.key, required this.title, required this.dayNumber});

  final String title;
  final String dayNumber;

  @override
  State<DevelopPlanScreen> createState() => _DevelopPlanScreenState();
}

class _DevelopPlanScreenState extends State<DevelopPlanScreen> {
  List<bool> _isSelected = [true, false];
  var _selectedDayIndex = 0;
  List<List<Map<String, String>>> planList = [];

  @override
  void initState() {
    super.initState();
    // 最初に選択されているDayは1日目というのを設定している
    _isSelected = List.generate(int.parse(widget.dayNumber), (index) {
      if (index == 0) {
        return true;
      }
      return false;
    });
    // 要素が全て一体化？してしまうためgenerateを使って要素を別々にする
    // planList = List.filled(int.parse(widget.dayNumber), []);
    planList = List.generate(int.parse(widget.dayNumber), (index) => []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // todo Post button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: SizedBox(
              width: 120,
              height: 40,
              // todo Post Button
              child: ElevatedButton(
                onPressed: () {
                  // print(zeros);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff4B4B5A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    shadowColor: Colors.transparent),
                child: const Text(
                  'Post',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // Add plan button
      floatingActionButton: SizedBox(
        width: 230,
        height: 90,
        // done Add plan Button
        child: ElevatedButton(
          onPressed: () async {
            // newPlanListは辞書型
            final newPlanMap = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddPlanScreen()));
            // print(newPlanList);
            if (newPlanMap != null) {
              setState(() {
                // planListにAddPlanScreenから渡されたMapを追加
                // List.filledでは全ての要素を埋めて、一つになってしまう（値を追加したらインデックスを指定しても全てのリストに追加されてしまう）ので、List.generateで対応
                planList[_selectedDayIndex].add(newPlanMap);
              });
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff4B4B5A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              shadowColor: Colors.transparent),
          child: const Icon(
            Icons.add,
            size: 50,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 37,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // todo edit button
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: SizedBox(
              width: 100,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  print('Pressed Edit Button!');
                },
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Color(0xff4B4B5A), width: 3),
                  ),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Color(0xff4B4B5A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
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
                      print(_selectedDayIndex);
                    });
                    // DONE implement the feature of List or Map!!! on line 93
                    // これはStateNotifierを使わなければいけない事態が発生している気がする
                    // 発生してなかったよ
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
                    int.parse(widget.dayNumber),
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

          planList[_selectedDayIndex].isEmpty
              ? const Text('you can add some')
              : SizedBox(
                  height: 500,
                  child: ListView.builder(
                    itemCount: planList[_selectedDayIndex].length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Text(planList[_selectedDayIndex][index]['startTime']
                              .toString()),
                          const SizedBox(width: 10,),
                          const Text('-'),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(planList[_selectedDayIndex][index]['endTime']
                              .toString()),
                          const SizedBox(width: 20,),
                          Text(planList[_selectedDayIndex][index]['title']
                              .toString()),
                        ],
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
