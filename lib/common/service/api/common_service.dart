import 'dart:convert';

import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stakBread/common/manager/logger.dart';
import 'package:stakBread/common/manager/session_manager.dart';
import 'package:stakBread/common/service/api/api_service.dart';
import 'package:stakBread/common/service/utils/params.dart';
import 'package:stakBread/common/service/utils/web_service.dart';
import 'package:stakBread/model/general/file_path_model.dart';
import 'package:stakBread/model/general/location_place_model.dart';
import 'package:stakBread/model/general/place_detail.dart';
import 'package:stakBread/model/general/settings_model.dart';
import 'package:stakBread/model/general/status_model.dart';
import 'package:stakBread/utilities/app_res.dart';
import 'package:stakBread/utilities/const_res.dart';

class CommonService {
  CommonService._();

  static final CommonService instance = CommonService._();

  Future<bool> fetchGlobalSettings() async {
    SettingModel settingsModel = await ApiService.instance.call(
        url: WebService.setting.fetchSettings,
        fromJson: SettingModel.fromJson,
        cancelAuthToken: true);

    var setting = settingsModel.data;
    if (setting != null) {
      SessionManager.instance.setSettings(setting);
      return true;
    }
    return false;
  }

  Future<FilePathModel> uploadFileGivePath(XFile files,
      {Function(double percentage)? onProgress}) async {
    FilePathModel model = await ApiService.instance.multiPartCallApi(
      url: WebService.setting.uploadFileGivePath,
      filesMap: {
        Params.file: [files]
      },
      onProgress: onProgress,
      fromJson: FilePathModel.fromJson,
    );

    return model;
  }

  Future<StatusModel> deleteFile(String filePath) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.setting.deleteFile,
        param: {Params.filePath: filePath},
        fromJson: StatusModel.fromJson);
    return model;
  }

  /// Dummy places for useDummyApi (location search).
  static List<Map<String, dynamic>> _dummyPlaces() => [
        {
          'name': 'places/dummy_1',
          'id': 'dummy_place_1',
          'displayName': {'text': 'Demo Cafe', 'languageCode': 'en'},
          'formattedAddress': '123 Demo St, Demo City, DC 10001',
          'addressComponents': [
            {'longText': 'Demo City', 'shortText': 'DC', 'types': ['administrative_area_level_3']},
            {'longText': 'Demo State', 'shortText': 'DS', 'types': ['administrative_area_level_1']},
            {'longText': 'Demo Country', 'shortText': 'DC', 'types': ['country']},
          ],
          'location': {'latitude': 28.5355, 'longitude': 77.3910},
        },
        {
          'name': 'places/dummy_2',
          'id': 'dummy_place_2',
          'displayName': {'text': 'Central Park', 'languageCode': 'en'},
          'formattedAddress': '456 Park Ave, Metro City',
          'addressComponents': [
            {'longText': 'Metro City', 'shortText': 'MC', 'types': ['administrative_area_level_3']},
            {'longText': 'New State', 'shortText': 'NS', 'types': ['administrative_area_level_1']},
            {'longText': 'Demo Country', 'shortText': 'DC', 'types': ['country']},
          ],
          'location': {'latitude': 28.6129, 'longitude': 77.2295},
        },
        {
          'name': 'places/dummy_3',
          'id': 'dummy_place_3',
          'displayName': {'text': 'Tech Hub Office', 'languageCode': 'en'},
          'formattedAddress': '789 Innovation Rd, Startup Town',
          'addressComponents': [
            {'longText': 'Startup Town', 'shortText': 'ST', 'types': ['administrative_area_level_3']},
            {'longText': 'Demo State', 'shortText': 'DS', 'types': ['administrative_area_level_1']},
            {'longText': 'Demo Country', 'shortText': 'DC', 'types': ['country']},
          ],
          'location': {'latitude': 28.7041, 'longitude': 77.1025},
        },
      ];

  Future<List<Places>> searchPlace({String title = ''}) async {
    if (useDummyApi) {
      final list = _dummyPlaces().map((e) => Places.fromJson(e)).toList();
      Loggers.info('Dummy location search: ${list.length} places');
      return list;
    }
    Setting? settings = SessionManager.instance.getSettings();

    Map<String, String> header = {
      Params.authorization:
          'Bearer ${settings?.placeApiAccessToken ?? 'PLACE API ACCESS TOKEN EMPTY'}'
    };

    Map<String, dynamic> body = {
      Params.textQuery: title,
      Params.maxResultCount: '${AppRes.paginationLimit}'
    };

    Uri uri = Uri.parse(WebService.google.searchTextByPlace);

    Loggers.info(uri);
    Loggers.info(header);
    Loggers.info(body);

    Response response = await post(uri, headers: header, body: body);
    LocationPlaceModel model =
        LocationPlaceModel.fromJson(jsonDecode(response.body));

    Loggers.error(model.error?.toJson() ?? 'NO ERROR');
    Loggers.success(model.places?.map((e) => e.toJson()));

    return model.places ?? [];
  }

  Future<List<Places>> searchNearBy(
      {required double lat, required double lon}) async {
    if (useDummyApi) {
      final list = _dummyPlaces().map((e) => Places.fromJson(e)).toList();
      Loggers.info('Dummy nearby location: ${list.length} places');
      return list;
    }
    Setting? settings = SessionManager.instance.getSettings();

    Map<String, String> header = {
      Params.authorization:
          'Bearer ${settings?.placeApiAccessToken ?? 'PLACE API ACCESS TOKEN EMPTY'}'
    };
    Map<String, dynamic> locationRestriction = {
      Params.circle: {
        Params.center: {Params.latitude: '$lat', Params.longitude: '$lon'},
        Params.radius: '${AppRes.nearBySearchRadius}'
      }
    };
    Map<String, dynamic> body = {
      Params.includedTypes: AppRes.nearbySearchTypes,
      Params.maxResultCount: AppRes.paginationLimit.toString(),
      Params.locationRestriction: locationRestriction
    };

    Uri uri = Uri.parse(WebService.google.searchNearByPlace(lat, lon));

    Loggers.info('URI : $uri');
    Loggers.info('HEADER : $header');
    Loggers.info('BODY : $body');
    Response response =
        await post(uri, headers: header, body: jsonEncode(body));
    LocationPlaceModel model =
        LocationPlaceModel.fromJson(jsonDecode(response.body));

    Loggers.error(model.error?.toJson() ?? 'NO ERROR');
    Loggers.success(model.places?.map((e) => e.toJson()));

    return model.places ?? [];
  }

  Future<PlaceDetail> getIPPlaceDetail() async {
    if (useDummyApi) {
      return PlaceDetail(
        status: 'success',
        country: 'Demo Country',
        countryCode: 'DC',
        region: 'DS',
        regionName: 'Demo State',
        city: 'Demo City',
        zip: '10001',
        lat: 28.5355,
        lon: 77.3910,
        timezone: 'Asia/Kolkata',
        isp: 'Demo ISP',
        org: 'Demo Org',
        query: '127.0.0.1',
      );
    }
    Map<String, dynamic> detail =
        await ApiService.instance.callGet(url: WebService.common.ipApi);
    return PlaceDetail.fromJson(detail);
  }
}
