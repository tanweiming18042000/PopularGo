import 'package:flutter/material.dart';
import 'package:populargo/features/auth/services/auth_service.dart';
import 'package:populargo/features/home/components/category_body.dart';

import '../../../constants/global_variables.dart';
import '../../../constants/size_config.dart';
import '../../../models/book.dart';
import '../../../models/feature.dart';
import 'feature_body.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories>
    with SingleTickerProviderStateMixin {
  //backend connection
  final AuthService authService = AuthService();

  // get all the books with the genre
  Future<List<Book>> getBooks(String bookGenre) {
    return authService.getBooks(context: context, genre: bookGenre);
  }

  late TabController _tabController;
  List<String> categories = [
    "Featured",
    "English",
    "Biology",
    "Chemistry",
    "Physics",
    "Documentary",
    "Fiction",
    "Children Book",
    "Cook Book"
  ];

  List<String> scienceCategories = [
    "Biology",
    "Chemistry",
    "Physics",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return DefaultTabController(
        length: categories.length,
        child: Expanded(
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              flexibleSpace: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      physics: BouncingScrollPhysics(),
                      labelColor: GlobalVariables.selectedNavBarColor,
                      unselectedLabelColor:
                          GlobalVariables.unselectedNavBarColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          color: GlobalVariables.greyBackgroundColor),
                      tabs: [
                        for (int i = 0; i < categories.length; i++)
                          Tab(
                            child: Text(categories[i]),
                          ),
                      ]),
                ],
              ),
            ),
            body: TabBarView(controller: _tabController, children: <Widget>[
              // feature tab  body
              FeatureBody(categories, _tabController),
              // english tab body
              SingleChildScrollView(child: CategoryBody(categories[1], getBooks)),
              SingleChildScrollView(child: CategoryBody(categories[2], getBooks)),
              SingleChildScrollView(child: CategoryBody(categories[3], getBooks)),
              SingleChildScrollView(child: CategoryBody(categories[4], getBooks)),
              SingleChildScrollView(child: CategoryBody(categories[5], getBooks)),
              SingleChildScrollView(child: CategoryBody(categories[6], getBooks)),
              SingleChildScrollView(child: CategoryBody(categories[7], getBooks)),
              SingleChildScrollView(child: CategoryBody(categories[8], getBooks)),
            ]),
          ),
        ));
  }
}
