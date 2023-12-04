import 'package:flutter/material.dart';

// library import
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travelknock/components/cards/plans/plan_details_bottom_sheet.dart';

class PlanDetailsCard extends StatefulWidget {
  const PlanDetailsCard(
      {super.key, required this.planList, required this.isDevelop});

  final List planList;
  final bool isDevelop;

  @override
  State<PlanDetailsCard> createState() => _PlanDetailsCardState();
}

class _PlanDetailsCardState extends State<PlanDetailsCard> {
  List<List<Map<String, String>>> plans = [];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    Widget planTimeWidget(int index) {
      return Row(
        children: [
          Text(
            widget.planList[index]['startTime'],
            style: const TextStyle(
              color: Color(0xff797979),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: width * 0.01), // 5
          const Text(
            '-',
            style: TextStyle(
              color: Color(0xff797979),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: width * 0.01), // 5
          Text(
            widget.planList[index]['endTime'],
            style: const TextStyle(
              color: Color(0xff797979),
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      );
    }

    void showPlanDetailsCardBottomSheet(
        String title, String imageUrl, Widget planTimeWidget) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(50),
            topLeft: Radius.circular(50),
          ),
        ),
        builder: (context) {
          return PlanDetailsBottomSheet(
            title: title,
            imageUrl: imageUrl,
            planTimeWidget: planTimeWidget,
          );
        },
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: height * 0.05), // 50n0.05
      itemCount: widget.planList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            showPlanDetailsCardBottomSheet(
              widget.planList[index]['title'],
              widget.planList[index]['imageUrl'],
              planTimeWidget(index),
            );
          },
          child: Container(
            padding: EdgeInsets.only(bottom: height * 0.1),
            child: Stack(
              alignment: Alignment.bottomCenter, // topRightでもいい
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: width * 0.75, // 290
                  height: width >= 500 ? width >= 1000 ? height * 0.4:height * 0.3 : height * 0.25, // 210
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Card(
                    child: CachedNetworkImage(
                      imageUrl: widget.planList[index]['imageUrl'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: width >= 500 ? width >= 1000 ? height * 0.3:height * 0.25 : height * 0.16, // 150
                  child: Container(
                    constraints: BoxConstraints(maxHeight: height * 0.14),
                    width: width * 0.8, // 310
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
                            // padding: EdgeInsets.only(
                            //     top: height * 0.025, left: width * 0.05, bottom: height * 0.008),
                            child: planTimeWidget(index)),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                // left: width * 0.05
                                padding: EdgeInsets.only(
                                    left: 20,
                                    bottom: height * 0.025,
                                    right: 10),
                                child: Text(
                                  widget.planList[index]['title'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.isDevelop)
                  Positioned(
                    top: -10,
                    right: 40,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xff4B4B5A),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            widget.planList.removeAt(index);
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
            // ),
          ),
        );
      },
    );
  }
}
