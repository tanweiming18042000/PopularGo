import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:populargo/features/home/components/category_bar.dart';
import 'package:populargo/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../../../constants/size_config.dart';
import '../components/recommendationPage.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //user.toJson(),
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: buildAppBar(),
      body: CategoryBar(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      title: Text('Books'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.thumb_up),
          onPressed: () {
            Navigator.pushNamed(context, RecommendationPage.routeName);
          },
        ),
          SizedBox(
            width: getProportionateScreenWidth(10),
          ),
      ],
    );
    
  }
}
