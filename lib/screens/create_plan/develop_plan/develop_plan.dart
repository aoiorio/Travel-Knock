import 'package:flutter/material.dart';

// libraries import
import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// screens import
import 'package:travelknock/screens/create_plan/develop_plan/add_plan.dart';
import 'package:travelknock/screens/create_plan/develop_plan/edit_plan.dart';
import 'package:travelknock/screens/create_plan/new_plan.dart';
import 'package:travelknock/screens/tabs.dart';

// component import
import 'package:travelknock/components/cards/plans/plan_details_card.dart';

class DevelopPlanScreen extends StatefulWidget {
  const DevelopPlanScreen({
    super.key,
    required this.title,
    required this.dayNumber,
    required this.placeName,
    this.planList,
    required this.isKnock,
  });

  final String title;
  final String dayNumber;
  final String placeName;
  final List<List<Map<String, String>>>? planList;
  final bool isKnock;

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
  bool isPlanListNotSameLength = false;

  @override
  void initState() {
    super.initState();
    final dayNumber = widget.dayNumber;
    print("dayNumber: $dayNumber");
    // 最初に選択されているDayは1日目というのを設定している
    _isSelected = List.generate(int.parse(widget.dayNumber), (index) {
      if (index == 0) {
        return true;
      }
      return false;
    });

    if (widget.planList != null) {
      planList = widget.planList!;
      if (planList.length < int.parse(widget.dayNumber)) {
        planList = List.generate(int.parse(widget.dayNumber), (index) => []);
        for (var i = 0; widget.planList!.length < planList.length; i++) {
          // edit feature, input values!
          try {
            planList[i] = widget.planList![i];
          } on RangeError {
            print('please ignore a range error!');
            break;
          }
        }
      }
      return;
    }
    // 要素が全て一体化？してしまうためgenerateを使って要素を別々にする
    // planList = List.filled(int.parse(widget.dayNumber), []);
    planList = List.generate(int.parse(widget.dayNumber), (index) => []);
  }

  String _generateRandomString() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

// saveDataToSupabase(String databaseName)と定義して、Knockにも対応する
  void saveDataToSupabase() async {
    if (image == null) {
      return;
    }
    setState(() {
      isLoading = true;
      // print(isLoading);
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
    String imageUrl = supabase.storage.from('posts').getPublicUrl(imagePath);
    setState(() {
      imageUrl = Uri.parse(imageUrl).replace(
          queryParameters: {'t': DateTime.now().toIso8601String()}).toString();
    });
    setState(() {
      _imageUrl = imageUrl;
    });

    // 一番要素数の多いListにほかのListの要素数も合わせる
    int maxLength = planList.fold(
        0, (max, subList) => max > subList.length ? max : subList.length);

    // エラーが起きないように各日のリストの要素数を合わせる
    // 各サブリストを最大の長さに拡張
    List<List<Map>> expandedPlansList = planList.map((subList) {
      // maxLengthと合わせるために残り幾つ空のMapを追加するか => maxLength - subList.length
      List<Map> expandedPlanSubList = List<Map>.from(subList);
      expandedPlanSubList
          .addAll(List<Map>.filled(maxLength - subList.length, {}));
      return expandedPlanSubList;
    }).toList();

    try {
      await supabase.from('posts').insert({
        'user_id': supabase.auth.currentUser!.id,
        'title': widget.title,
        'thumbnail': _imageUrl,
        'plans': expandedPlansList, // plans: text[], plans_list: jsonb[]
        'place_name': widget.placeName,
      });
      // print('planList: $planList');
    } catch (e) {
      debugPrint(e.toString());
      debugPrint('error-planList: $planList');
      debugPrint("something went wrong");
      return;
    }
    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
    Navigator.pop(context); // これ消すかみる

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) {
          return const TabsScreen(
            initialPageIndex: 0,
          );
        },
      ),
      (route) {
        return false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // width and height
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // developPageから戻るときに変更を破棄していいかconfirmする
    return WillPopScope(
      onWillPop: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Do you want to quit 🌞?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  // color: Color(0xff4B4B5A),
                ),
              ),
              content: const Text('Your all plans that you made will discard'),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                Container(
                  width: 100,
                  height: 50,
                  margin: EdgeInsets.only(bottom: height * 0.03),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff4B4B5A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Yes'),
                    onPressed: () async {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const NewPlanScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 30),
                Container(
                  width: 100,
                  height: 50,
                  margin: EdgeInsets.only(bottom: height * 0.03),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xfff2f2f2),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('No'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                )
              ],
            );
          },
        );
        return Future(() => true);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        // Post button
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
          toolbarHeight: width >= 500 ? 100 :null,
          actions: [
            Container(
              margin: EdgeInsets.only(top: width >= 500 ? 20: 0),
              padding: const EdgeInsets.only(right: 20, ),
              child: SizedBox(
                width: 120,
                height: 40,
                // done Post Button
                child: ElevatedButton(
                  onPressed: () {
                    // After pressed post button
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
                                  // crossAxisAlignment: CrossAxisAlignment.center,
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
                                    Center(
                                      child: Stack(
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
                                                        image:
                                                            FileImage(image!),
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
                                                  source: ImageSource.gallery,
                                                );
                                                if (image == null) {
                                                  return;
                                                }
                                                final imagePath =
                                                    File(image.path);

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
                                    ),
                                    Center(
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          top: 30,
                                        ),
                                        width: 130,
                                        height: 60,
                                        child: isLoading
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Color(0xff4B4B5A),
                                                ),
                                              )
                                            : ElevatedButton(
                                                // DONE implement features of post, connect to database
                                                onPressed: () async {
                                                  final planListLengths = [];

                                                  for (var plan in planList) {
                                                    setState(
                                                      () {
                                                        planListLengths
                                                            .add(plan.length);
                                                      },
                                                    );
                                                  }

                                                  setState(() {
                                                    // planListの要素数が一緒ではなかったらtrueを返すそしてsnackbarを表示させる
                                                    // planListの中の要素が一つでも空だったらtrueを返す
                                                    print(planList);
                                                    for (var plan in planList) {
                                                      planListLengths
                                                          .add(plan.length);
                                                      if (plan.isEmpty) {
                                                        isEmpty = true;
                                                      } else {
                                                        isEmpty = false;
                                                      }
                                                    }
                                                    // print(planListLengths);
                                                  });
                                                  // 1 Dayだけを選択した人もinclude, すべてのplanの数が同じじゃないとエラーだからそれも察知するif文
                                                  try {
                                                    if (image == null ||
                                                        isEmpty) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              "You have to sure that all days have plans and set the thumbnail"),
                                                          backgroundColor:
                                                              Color(0xff4B4B5A),
                                                        ),
                                                      );
                                                      Navigator.of(context)
                                                          .pop();
                                                      return;
                                                    }
                                                  } on Exception catch (e) {
                                                    print(e);
                                                    print(
                                                        'Something went wrong with picking image at develop_plan.dart');
                                                    return;
                                                  }
                                                  saveDataToSupabase();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xff4B4B5A),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
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
                                    ),
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
                  MaterialPageRoute(
                      builder: (context) => const AddPlanScreen()));
              // print(newPlanList);
              if (newPlanMap != null) {
                setState(() {
                  print(newPlanMap);
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
        // add plan button's location
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
              // done edit button
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: SizedBox(
                  width: 100,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      print('Pressed Edit Button!');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return EditPlanScreen(
                              planTitleText: widget.title,
                              placeName: widget.placeName,
                              period: widget.dayNumber,
                              plans: planList,
                            );
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(
                            color: Color(0xff4B4B5A), width: 3),
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
              // illustration of none
              planList[_selectedDayIndex].isEmpty
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: widget.title.length >= 18
                            ? width >= 500
                                ? width >= 1000
                                    ? height * 0.01
                                    : height * 0.1
                                : height * 0.03
                            : width >= 500
                                ? width >= 1000
                                    ? height * 0.05
                                    : height * 0.1
                                : height * 0.045,
                      ), // 40
                      child: Column(
                        children: [
                          Center(
                            child: SizedBox(
                              width: width >= 500
                                  ? width * 0.35
                                  : width * 0.5, // 250
                              height:
                                  width >= 1000 ? 270 : height * 0.28, // 250
                              child: Image.asset(
                                'assets/images/nothing-plan.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.only(right: 10),
                              child: const Text(
                                'No plans yet!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : PlanDetailsCard(
                      planList: planList[_selectedDayIndex],
                      isDevelop: true,
                    ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
