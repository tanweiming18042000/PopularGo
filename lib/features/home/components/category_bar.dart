import 'package:flutter/material.dart';
import 'package:populargo/constants/global_variables.dart';
import 'package:populargo/constants/size_config.dart';

import 'categories.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Categories(),
        // create the bracket featured squared bracket
      ],
    );
  }
}
