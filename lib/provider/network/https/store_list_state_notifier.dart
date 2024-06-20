import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_web/services/debug_services.dart';
import 'package:orre_web/model/store_list_model.dart';
import 'package:orre_web/provider/home_screen/store_list_sort_type_provider.dart';
import 'package:orre_web/services/network/https_services.dart';

class StoreListParameters {
  StoreListSortType sortType;
  double latitude;
  double longitude;
  StoreListParameters(
      {required this.sortType,
      required this.latitude,
      required this.longitude});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StoreListParameters &&
        other.sortType == sortType &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(sortType, latitude, longitude);
}

final storeListProvider =
    StateNotifierProvider<StoreListNotifier, List<StoreLocationInfo>>((ref) {
  return StoreListNotifier();
});

class StoreListNotifier extends StateNotifier<List<StoreLocationInfo>> {
  StoreListNotifier() : super([]);
  final paramsMap = <StoreListParameters, List<StoreLocationInfo>>{};

  Future<void> fetchStoreDetailInfo(StoreListParameters params) async {
    try {
      if (paramsMap.containsKey(params)) {
        printd(
            "Already requested!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        state = paramsMap[params]!;
        return;
      } else {
        String sortType = params.sortType.toEn();
        double latitude = params.latitude;
        double longitude = params.longitude;
        printd("sortType: $sortType");
        printd("latitude: $latitude, longitude: $longitude");

        final baseUrl = dotenv.get('ORRE_HTTPS_ENDPOINT_STORELIST') + sortType;
        final body = {
          'latitude': latitude,
          'longitude': longitude,
        };
        final url = '$baseUrl?latitude=$latitude&longitude=$longitude';

        final jsonBody = json.encode(body);
        printd('jsonBody: $jsonBody');

        final response = await HttpsService.getRequest(url);

        if (response.statusCode == 200) {
          final jsonBody = json.decode(utf8.decode(response.bodyBytes));
          printd('jsonBody: $jsonBody');
          final result = (jsonBody as List)
              .map((e) => StoreLocationInfo.fromJson(e))
              .toList();
          paramsMap.clear();
          printd('result: $result');
          paramsMap.addEntries([MapEntry(params, result)]);
          printd(
              "paramsMap: $paramsMap!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
          state = result;
        } else {
          printd('response.statusCode: ${response.statusCode}');
          paramsMap.clear();
          paramsMap.addEntries([MapEntry(params, [])]);
          state = [];
          throw Exception('Failed to fetch store info');
        }
      }
    } catch (error) {
      state = [];
      throw Exception('Failed to fetch store info');
    }
  }

  bool isExistRequest(StoreListParameters params) {
    return paramsMap.containsKey(params);
  }
}
