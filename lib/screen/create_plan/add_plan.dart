import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelknock/components/custom_text_field.dart';

class AddPlanScreen extends StatefulWidget {
  const AddPlanScreen({
    super.key,
  });

  @override
  State<AddPlanScreen> createState() => _AddPlanScreenState();
}

class _AddPlanScreenState extends State<AddPlanScreen> {
  var stringStartTime = '${DateTime.now().hour}:${DateTime.now().minute}';
  var stringEndTime = '${DateTime.now().hour}:${DateTime.now().minute}';
  var endTime = DateTime.now();
  var startTime = DateTime.now();
  Map<String, String> planList = {};

  File? image;
  final planDetailTitleController = TextEditingController();

  // asyncの同期を終わるまで待ってしまうから？ここにpickImageをおかないとTimeが動作しない
  Future<void> pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      // 画像がnullの場合戻る
      if (image == null) return;
      final imagePath = File(image.path);

      setState(() {
        this.image = imagePath;
      });
      print(imagePath);
    } on Exception {
      print('something went wrong with picking image');
    }
  }

  void _showModalPicker(BuildContext context, String time) {
    var stringStartTimeMinute = '';
    var stringEndTimeMinute = '';
    var initialDateTime = DateTime.now();
    // モーダルを呼び出しているのが始まりか終わりのどっちなのかをinitialDateTimeに格納する
    if (time == 'startTime') {
      initialDateTime = startTime;
    } else {
      initialDateTime = endTime;
    }

    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 3,
          padding: const EdgeInsets.all(20),
          child: CupertinoDatePicker(
            initialDateTime: initialDateTime,
            mode: CupertinoDatePickerMode.time,
            onDateTimeChanged: (value) {
              setState(() {
                if (time == 'startTime') {
                  startTime = value;
                  stringStartTimeMinute = startTime.minute.toString();
                  // 分のところにうしろに0がついていたら0を増やす
                  if (stringStartTimeMinute.length == 1) {
                    stringStartTimeMinute = '0$stringStartTimeMinute';
                  }
                  // 最終的にこの値がstartTimeになる
                  stringStartTime = '${startTime.hour}:$stringStartTimeMinute';
                  print(stringStartTime);
                } else {
                  endTime = value;
                  stringEndTimeMinute = endTime.minute.toString();
                  // 分のところにうしろに0がついていたら0を増やす
                  if (stringEndTimeMinute.length == 1) {
                    stringEndTimeMinute = '0$stringEndTimeMinute';
                  }
                  // 最終的にこの値がendTimeになる
                  stringEndTime = '${endTime.hour}:$stringEndTimeMinute';
                }
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 現在時刻に0を増やす作戦
    if (DateTime.now().minute.toString().length == 1) {
      stringStartTime = '${DateTime.now().hour}:0${DateTime.now().minute}';
      stringEndTime = '${DateTime.now().hour}:0${DateTime.now().minute}';
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 110, left: 35),
              child: Text(
                'Add Plan 📌',
                style: TextStyle(
                  fontSize: 37,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 35),
              child: CustomTextField(
                title: 'Title',
                labelText: 'e.g. Eat at Banta Cafe',
                controller: planDetailTitleController,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 40, left: 35),
              child: Text(
                'Time',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 35),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        _showModalPicker(context, 'startTime');
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xffEEEEEE),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        stringStartTime,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  const Text(
                    '-',
                    style: TextStyle(fontSize: 30),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  SizedBox(
                    width: 120,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        _showModalPicker(context, 'endTime');
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xffEEEEEE),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        stringEndTime,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 40, left: 35),
              child: Text(
                'Photo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 20, left: 35),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 320,
                    height: 190,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
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
                    onPressed: pickImage,
                    icon: const Icon(
                      Icons.photo,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30, top: 35),
              child: Center(
                child: SizedBox(
                  width: 170,
                  height: 70,
                  child: ElevatedButton(
                    // TODO add feature of add to the list button
                    onPressed: () {
                      if (planDetailTitleController.text.isEmpty ||
                          image == null) {
                        return;
                      }
                      planList = {
                        'title': planDetailTitleController.text,
                        'startTime': stringStartTime,
                        'endTime': stringEndTime,
                      };
                      Navigator.of(context).pop(planList);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff4B4B5A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Add',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
