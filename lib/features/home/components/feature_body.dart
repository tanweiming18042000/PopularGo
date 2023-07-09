import 'package:flutter/material.dart';

import '../../../constants/size_config.dart';
import '../../../models/feature.dart';

SingleChildScrollView FeatureBody(
    List<String> categories, TabController _tabController) {
  return SingleChildScrollView(
    physics: BouncingScrollPhysics(),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < categories.length - 1; i++)
            GestureDetector(
              // go to the respective tabbar
              onTap: () {
                _tabController.animateTo(features[i].id);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                child: PhysicalModel(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                  clipBehavior: Clip.antiAlias,
                  elevation: 2,
                  child: Container(
                    height: getProportionateScreenHeight(180),
                    width: double.infinity,
                    child: Stack(children: [
                      Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(features[i].image),
                      ))),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          widthFactor: 1.0,
                          heightFactor: 0.2,
                          child: Container(
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(12.0, 0, 12.0, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    features[i].title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ]),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
