import 'package:flutter/material.dart';

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
  }

  @override
  Widget build(BuildContext context) {

    final planList = [
      [
        {'title': 'Eat at Banta cafe', 'time': '7.a.m - 8.a.m'},
        {'title': 'Go to the zoo', 'time': '9.a.m - 10.a.m'},
      ],
      [
        {'title': 'watch at movie theater', 'time': '7.a.m - 8.a.m'},
        {'title': 'Eat lunch at Komuginodorei', 'time': '9.a.m - 10.a.m'},
      ],
    ];
    print(planList[0][1]['title']);

    return Scaffold(
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
                onPressed: () {},
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
      floatingActionButton: SizedBox(
        width: 230,
        height: 90,
        // todo Add plan Button
        child: ElevatedButton(
          onPressed: () {},
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
                  print('object');
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
                    });
                    // TODO implement the feature of List or Map!!!
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
                      (index + 1).toString() + ' Day',
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
        ],
      ),
    );
  }
}
