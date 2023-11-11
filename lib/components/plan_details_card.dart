import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// class PlanDetailsCard extends StatefulWidget
class PlanDetailsCard extends StatefulWidget {
  const PlanDetailsCard(
      {super.key, required this.planList, required this.isDevelop});

  final List planList;
  final bool isDevelop;

  @override
  State<PlanDetailsCard> createState() => _PlanDetailsCardState();
}

class _PlanDetailsCardState extends State<PlanDetailsCard> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 50),
      itemCount: widget.planList.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 0),
          padding: const EdgeInsets.only(bottom: 70),
          constraints: const BoxConstraints(minHeight: 200),
          child: Container(
              constraints: const BoxConstraints(minHeight: 200),
              margin: const EdgeInsets.only(bottom: 80),
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
                        child: CachedNetworkImage(
                          imageUrl: widget.planList[index]['imageUrl'],
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
                          margin: const EdgeInsets.only(bottom: 100),
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
                                      widget.planList[index]['startTime']!,
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
                                      widget.planList[index]['endTime']!,
                                      style: const TextStyle(
                                        color: Color(0xff797979),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Flexible(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, bottom: 20, right: 10),
                                      child: Text(
                                        widget.planList[index]['title']!,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
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
              ),
        );
      },
    );
  }
}
