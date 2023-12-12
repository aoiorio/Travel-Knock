import 'package:flutter/material.dart';

// libraries import
import 'package:supabase_flutter/supabase_flutter.dart';

// screens import
import 'package:travelknock/screens/tabs.dart';

// components import
import 'package:travelknock/components/cards/search/search_results_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.yourLikePostsData,
    this.searchText,
  });

  final List yourLikePostsData;
  final String? searchText;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final supabase = Supabase.instance.client;
  final searchTextController = TextEditingController();
  bool isResult = false;
  bool _isLoading = false;
  List _searchResult = [];
  final _controller = ScrollController();
  final List _userAvatar = [];

  void getUserInfo() {
    for (var i = 0; _searchResult.length > i; i++) {
      final userData = supabase
          .from('profiles')
          .select('*')
          .eq('id', _searchResult[i]['user_id'])
          .single();
      _userAvatar.add(userData);
      // print(_userAvatar);
    }
  }

  PreferredSizeWidget _appBarContent = AppBar(
    elevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.black,
  );

  void search() async {
    setState(() {
      _isLoading = true;
    });
    final searchResult = await supabase
        .from('posts')
        .select('*')
        .textSearch('place_name', searchTextController.text);
    if (!mounted) return;
    setState(() {
      _searchResult = searchResult;
      // print(_searchResult);
      _isLoading = false;
    });
  }

  void hotPlaceSearch(String searchText) async {
    setState(() {
      _isLoading = true;
    });
    final searchResult = await supabase
        .from('posts')
        .select('*')
        .textSearch('place_name', searchText);
    setState(() {
      _searchResult = searchResult;
      // print(_searchResult);
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.searchText != null) {
      searchTextController.text = widget.searchText!;
      hotPlaceSearch(widget.searchText!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return const TabsScreen(
                initialPageIndex: 0,
              );
            },
          ),
        );
        return Future.value(false);
      },
      child: Scaffold(
        appBar: _appBarContent,
        extendBodyBehindAppBar: true,
        body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollUpdateNotification) {
              setState(
                () {
                  _appBarContent = notification.metrics.pixels > 180
                      ? AppBar(
                          centerTitle: false,
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.black,
                          actions: [
                            const SizedBox(
                              width: 100,
                            ),
                            Expanded(
                              child: SizedBox(
                                child: Stack(
                                  alignment: Alignment.centerRight,
                                  children: [
                                    TextField(
                                      decoration: const InputDecoration(
                                        labelText: 'search plans',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                          ),
                                          borderSide: BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          ),
                                        ),
                                        fillColor: Color(0xffEEEEEE),
                                        filled: true,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                      ),
                                      controller: searchTextController,
                                      textInputAction: TextInputAction.search,
                                      cursorColor: const Color(0xff4B4B5A),
                                      onSubmitted: (value) {
                                        if (searchTextController.text
                                            .trim()
                                            .isEmpty) return;
                                        search();
                                        _controller.animateTo(
                                          0,
                                          duration:
                                              const Duration(milliseconds: 5),
                                          curve: Curves.easeInCirc,
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30, right: 10),
                                      child: IconButton(
                                        onPressed: () {
                                          if (searchTextController.text
                                              .trim()
                                              .isEmpty) return;
                                          search();
                                          _controller.animateTo(
                                            0,
                                            duration:
                                                const Duration(milliseconds: 5),
                                            curve: Curves.easeInCirc,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.search,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : AppBar(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.black,
                        );
                },
              );
            }
            return false;
          },
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              controller: _controller,
              child: Column(
                children: [
                  const SizedBox(
                    height: 130,
                  ),
                  _appBarContent ==
                          AppBar(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.black,
                          )
                      ? const SizedBox()
                      : Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: IconButton(
                                onPressed: () {
                                  if (searchTextController.text
                                      .trim()
                                      .isEmpty) {
                                    return;
                                  }
                                  search();
                                  setState(() {
                                    _appBarContent = AppBar(
                                      elevation: 0,
                                      foregroundColor: Colors.black,
                                      backgroundColor: Colors.transparent,
                                    );
                                  });
                                },
                                icon: const Icon(
                                  Icons.search,
                                  size: 30,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: SizedBox(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Search plans',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        bottomLeft: Radius.circular(20),
                                      ),
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                    fillColor: Color(0xffEEEEEE),
                                    filled: true,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                  ),
                                  controller: searchTextController,
                                  textInputAction: TextInputAction.search,
                                  cursorColor: const Color(0xff4B4B5A),
                                  onSubmitted: (value) {
                                    if (searchTextController.text
                                        .trim()
                                        .isEmpty) {
                                      return;
                                    }
                                    search();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                  _isLoading
                      ? Container(
                          padding: const EdgeInsets.all(100),
                          child: const CircularProgressIndicator(
                            color: Color(0xff4B4B5A),
                          ),
                        )
                      : searchTextController.text.isEmpty
                          // DONE add illustration (e.g. Let's search place name!)!
                          ? Padding(
                              padding: const EdgeInsets.only(top: 100),
                              child: Center(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width:
                                          width >= 1000 ? width * 0.5 : width,
                                      // margin: EdgeInsets.only(right: width * 0.1),
                                      child: Image.asset(
                                          'assets/images/first-search-potato.PNG'),
                                    ),
                                    const Text(
                                      "Let's enter a place name!",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SearchResultsCard(
                              searchResult: _searchResult,
                              searchText: widget.searchText != null
                                  ? widget.searchText!
                                  : searchTextController.text,
                              // yourLikePostsData: widget.yourLikePostsData,
                            ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
