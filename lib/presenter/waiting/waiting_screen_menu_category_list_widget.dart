import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:orre_web/presenter/storeinfo/menu/store_info_screen_menu_category_tile_widget.dart';
import 'package:orre_web/widget/text/text_widget.dart';

import '../../../../model/store_info_model.dart';

class WaitingScreenStoreMenuCategoryListWidget extends ConsumerWidget {
  final StoreDetailInfo storeDetailInfo;

  WaitingScreenStoreMenuCategoryListWidget({required this.storeDetailInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuCategories = storeDetailInfo.menuCategories;
    final categoryKR = menuCategories.getCategories();

    if (categoryKR.length < 2) {
      return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: 100.0.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 24.r,
              color: const Color(0xFFDFDFDF),
            ),
            TextWidget(
              '메뉴 정보가 없습니다.',
              color: const Color(0xFFDFDFDF),
              fontSize: 12.r,
            ),
          ],
        ),
      );
    } else {
      return StoreMenuCategoryTileWidget(storeDetailInfo: storeDetailInfo);
    }
  }
}
