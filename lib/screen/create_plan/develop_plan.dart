import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/screen/create_plan/add_plan.dart';
import 'package:travelknock/screen/tabs.dart';

class DevelopPlanScreen extends StatefulWidget {
  const DevelopPlanScreen({
    super.key,
    required this.title,
    required this.dayNumber,
    required this.placeName,
  });

  final String title;
  final String dayNumber;
  final String placeName;

  @override
  State<DevelopPlanScreen> createState() => _DevelopPlanScreenState();
}

class _DevelopPlanScreenState extends State<DevelopPlanScreen> {
  final supabase = Supabase.instance.client;
  List<bool> _isSelected = [true, false];
  var _selectedDayIndex = 0;
  List<List<Map<String, String>>> planList = [];
  File? image;
  String? _imageUrl;
  var isLoading = false;
  var isEmpty = false;

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

  String _generateRandomString() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  void saveDataToSupabase() async {
    if (image == null) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    final imageExtension = image!.path.split('.').last.toLowerCase();
    final imageBytes = await image!.readAsBytes();
    final userId = supabase.auth.currentUser!.id;
    String pathName = _generateRandomString();
    // final pathName = planDetailTitleController.text;

    // DONE imageの名前が被らないようにしたい
    final imagePath = '/$userId/$pathName';
    await supabase.storage.from('posts').uploadBinary(
          imagePath,
          imageBytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: 'image/$imageExtension',
          ),
        );
    setState(() {
      isLoading = false;
    });
    String imageUrl = supabase.storage.from('posts').getPublicUrl(imagePath);
    setState(() {
      imageUrl = Uri.parse(imageUrl).replace(
          queryParameters: {'t': DateTime.now().toIso8601String()}).toString();
    });
    setState(() {
      _imageUrl = imageUrl;
    });
    try {
      await supabase.from('posts').insert({
        'user_id': supabase.auth.currentUser!.id,
        'title': widget.title,
        'thumbnail': _imageUrl,
        'plans': planList,
        'place_name': widget.placeName,
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
                  // print('Pressed Post Button!');
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            content: Container(
                              padding: const EdgeInsets.only(top: 20),
                              width: 350,
                              height: 400,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pick Main Photo 🥚',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text(
                                    "This photo will be post's thumbnail",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff797979),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 320,
                                        height: 190,
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: const Color(0xffEEEEEE),
                                        ),
                                        child: image != null
                                            ? DecoratedBox(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: FileImage(image!),
                                                  ),
                                                ),
                                              )
                                            : const DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: Color(0xffEEEEEE),
                                                ),
                                              ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          try {
                                            final ImagePicker picker =
                                                ImagePicker();
                                            // Pick an image.
                                            final XFile? image =
                                                await picker.pickImage(
                                                    source:
                                                        ImageSource.gallery);
                                            if (image == null) {
                                              return;
                                            }
                                            final imagePath = File(image.path);

                                            setState(() {
                                              this.image = imagePath;
                                            });
                                          } on Exception {
                                            print(
                                                'something went wrong with picking image');
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.photo,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Center(
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          top: 30, left: 0), // left: 140
                                      width: 130,
                                      height: 60,
                                      // decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: const Color(0xff4B4B5A)),
                                      child: isLoading
                                          ? const CircularProgressIndicator()
                                          : ElevatedButton(
                                              // TODO implement features of post, connect to database
                                              onPressed: () async {
                                                if (image == null ||
                                                    planList.contains([]) ||
                                                    planList.isEmpty) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'You have to add plan and thumbnail'),
                                                      backgroundColor:
                                                          Color(0xff4B4B5A),
                                                    ),
                                                  );
                                                  return;
                                                }
                                                // print(planList);
                                                saveDataToSupabase();
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return const TabsScreen();
                                                    },
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xff4B4B5A),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                              ),
                                              child: const Text(
                                                'Post',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          );
                        },
                      );
                    },
                  );
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
                      side:
                          const BorderSide(color: Color(0xff4B4B5A), width: 3),
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
            // if there aren't any plans, the cute walrus will appear on the screen
            planList[_selectedDayIndex].isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        Center(
                          child: SizedBox(
                            width: 250,
                            height: 250,
                            child: Image.asset(
                              'assets/images/nothing-plan.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Center(
                          child: Text(
                            'No plans yet!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 50),
                    itemCount: planList[_selectedDayIndex].length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: Center(
                          child: Stack(
                            alignment: Alignment.bottomCenter, // topRightでもいい
                            clipBehavior: Clip.none,
                            // fit: StackFit.loose,
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
                                    planList[_selectedDayIndex][index]
                                        ['imageUrl']!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // TODO if users inputted many letters of plan's title, the letters will be new line.
                              Positioned(
                                top: 150,
                                child: Container(
                                  width: 310,
                                  height: 90,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20, left: 20, bottom: 7),
                                        child: Row(
                                          children: [
                                            Text(
                                              planList[_selectedDayIndex][index]
                                                  ['startTime']!,
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
                                              planList[_selectedDayIndex][index]
                                                  ['endTime']!,
                                              style: const TextStyle(
                                                color: Color(0xff797979),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Text(
                                          planList[_selectedDayIndex][index]
                                              ['title']!,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -10,
                                right: -7,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff4B4B5A),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      // print('Pressed delete button');
                                      setState(() {
                                        planList[_selectedDayIndex]
                                            .removeAt(index);
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.clear,
                                      size: 30,
                                    ),
                                    color: Colors.white,
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
