import 'package:flutter/material.dart';

// libraries import
import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// screens import
import 'package:travelknock/screens/create_plan/develop_plan/add_plan.dart';
import 'package:travelknock/screens/tabs.dart';

// component import
import 'package:travelknock/components/cards/plans/plan_details_card.dart';

class KnockDevelopScreen extends StatefulWidget {
  const KnockDevelopScreen({
    super.key,
    required this.title,
    required this.period,
    required this.destination,
    required this.requestUserAvatar,
    required this.requestUserName,
    required this.knockId,
  });

  final String title;
  final String period;
  final String destination;
  final String requestUserAvatar;
  final String requestUserName;
  final String knockId;

  @override
  State<KnockDevelopScreen> createState() => _KnockDevelopScreen();
}

class _KnockDevelopScreen extends State<KnockDevelopScreen> {
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
    _isSelected = List.generate(int.parse(widget.period), (index) {
      if (index == 0) {
        return true;
      }
      return false;
    });
    // 要素が全て一体化？してしまうためgenerateを使って要素を別々にする
    // planList = List.filled(int.parse(widget.dayNumber), []);
    planList = List.generate(int.parse(widget.period), (index) => []);
  }

  String _generateRandomString() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  void saveDataToSupabase() async {
    if (image == null) {
      return;
    }
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    final imageExtension = image!.path.split('.').last.toLowerCase();
    final imageBytes = await image!.readAsBytes();
    final userId = supabase.auth.currentUser!.id;
    String pathName = _generateRandomString();
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

    if (!mounted) return;

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

    // DONE connect to database
    await supabase.from('knock').update({
      'plans': expandedPlansList,
      'is_completed': true,
      'thumbnail': _imageUrl,
    }).eq('id', widget.knockId);
    setState(() {
      isLoading = false;
    });

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) {
          return const TabsScreen(
            initialPageIndex: 1,
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
    // final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
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
                                      "This photo will be a thumbnail",
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
                                    Center(
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            top: 30, left: 0), // left: 140
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
                                                  setState(() {
                                                    // planListの中の要素が一つでも空だったらtrueを返す
                                                    // DONE 編集をしてperiodを少なくしたら、以前のperiod分planを追加しないと投稿できないバグを直す
                                                    for (var plan in planList) {
                                                      if (plan.isEmpty) {
                                                        isEmpty = true;
                                                      } else {
                                                        isEmpty = false;
                                                      }
                                                    }
                                                  });
                                                  // 1 Dayだけを選択した人もinclude
                                                  if (image == null ||
                                                      isEmpty) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'You have to add plans and thumbnail',
                                                        ),
                                                        backgroundColor:
                                                            Color(0xff4B4B5A),
                                                      ),
                                                    );
                                                    Navigator.of(context).pop();
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
                                                  'Complete',
                                                  style: TextStyle(
                                                      fontSize: 17,
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
                    'Complete',
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
              shadowColor: Colors.transparent,
            ),
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
              // DONE RowにしてuserProfileScreenに飛べるようにしても良いかも（userNameだけ色かえる？）
              Container(
                margin: const EdgeInsets.only(left: 25),
                child: Text(
                  'Knocked by ${widget.requestUserName}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
                        int.parse(widget.period),
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
                      padding: const EdgeInsets.only(top: 25),
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
