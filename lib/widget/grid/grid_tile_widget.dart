// import 'package:flutter/material.dart';
import 'package:orre_web/services/debug.services.dart';
//
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_web/services/debug.services.dart';
// import 'package:orre_web/widget/text/text_widget.dart';

// import '../../provider/home_screen/store_category_provider.dart';

// class CategoryItem extends ConsumerWidget {
//   final StoreCategory category;

//   const CategoryItem({Key? key, required this.category}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final selectedTitle = ref.watch(selectCategoryProvider);

//     return ButtonBar(
//       children: [
//         ElevatedButton(
//           onPressed: () {
//             ref.read(selectCategoryProvider.notifier).state = category;
//             printd("category : " +
//                 ref.read(selectCategoryProvider.notifier).state.toKoKr());
//           },
//           child: TextWidget(
//             category.toKoKr(),
//             color: selectedTitle == category ? Colors.white : Colors.black,
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor:
//                 selectedTitle == category ? Color(0xFFFFFFBF52) : Colors.white,
//           ),
//         ),
//       ],
//     );
//   }
// }
