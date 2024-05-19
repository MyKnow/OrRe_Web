import 'package:flutter/material.dart';
import 'package:orre_web/services/debug.services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_web/services/debug.services.dart';
import 'package:orre_web/model/menu_info_model.dart';
import 'package:orre_web/presenter/storeinfo/menu/store_info_screen_menu_tilie_widget.dart';
import 'package:orre_web/widget/text/text_widget.dart';

import '../../../../model/store_info_model.dart';

class StoreMenuListWidget extends ConsumerWidget {
  final StoreDetailInfo storeDetailInfo;
  final String category;

  StoreMenuListWidget({
    required this.storeDetailInfo,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // print("category: $category");
    // storeDetailInfo.menuInfo.forEach((element) {
    //   printd("element: ${element.menuCode}");
    // });
    final menuList =
        MenuInfo.getMenuByCategory(storeDetailInfo.menuInfo, category);
    if (menuList.length < 1) {
      return Padding(
        padding: EdgeInsets.only(left: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextWidget(
              '메뉴 정보가 없습니다.',
              textAlign: TextAlign.start,
            )
          ],
        ),
      );
    } else {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: menuList.length,
        itemBuilder: (context, index) {
          final menu = menuList[index];
          return StoreMenuTileWidget(menu: menu);
        },
        separatorBuilder: (context, index) => Divider(
          color: Color(0xFFDFDFDF),
          thickness: 2,
          endIndent: 10,
          indent: 10,
        ),
      );
    }
  }
}
