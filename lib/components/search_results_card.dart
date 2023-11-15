import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SearchResultsCard extends StatelessWidget {
  const SearchResultsCard({
    super.key,
    required this.searchResult,
    required this.searchText,
  });

  final List searchResult;
  final String searchText;

  @override
  Widget build(BuildContext context) {
    List searchLike(int index) {
      final searchLike = searchResult[index]['post_like_users'];
      return searchLike;
    }

    return searchResult.isEmpty
        ? Image.asset('assets/images/no-knocked.PNG')
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 40,
              ),
              Text(
                '$searchText 🗝️ ${searchResult.length} results',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              ListView.builder(
                itemCount: searchResult.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 40),
                itemBuilder: (context, index) {
                  // if (index % 2 == 0) {
                  //   return;
                  // }
                  return Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      Container(
                        constraints:
                            const BoxConstraints(minHeight: 250, minWidth: 50),
                        width: 300,
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(top: 20, bottom: 40),
                        decoration: const BoxDecoration(
                          color: Color(0xffF2F2F2),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        alignment: Alignment.bottomLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: SizedBox(
                                width: 200,
                                child: Text(
                                  searchResult[index]['title'],
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text(
                                searchLike(index).length.toString(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 300,
                        height: 200,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: CachedNetworkImage(
                          imageUrl: searchResult[index]['thumbnail'],
                          fit: BoxFit.cover,
                        ),
                      )
                    ],
                  );
                },
              ),
            ],
          );
  }
}
