/*
* Copyright 2023 otomamay. All Rights Reserved.
*/
import 'dart:async';
import 'dart:convert';
import 'package:buy_navi/api_config.dart';
import 'package:buy_navi/service/local_notification.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class GooglePlacesService {
  static final GooglePlacesService _singleton = GooglePlacesService._internal();

  GooglePlacesService._internal();

  factory GooglePlacesService() {
    return _singleton;
  }

  String apiKey = ApiConfig.googlePlacesApiKey; // google places api key
  String searchQuery = '前橋駅';
  List<String> searchList = ['富士見中学校', 'ウェルシア']; // 検索リスト
  double latitude = 0.0;
  double longitude = 0.0;
  List<dynamic> nearbyPlaces = [];

  // serchQueryから経度と緯度を取得
  Future<void> searchPlaces() async {
    var encodedSearchQuery = Uri.encodeQueryComponent(searchQuery);
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$encodedSearchQuery&key=${ApiConfig.googlePlacesApiKey}');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var places = jsonDecode(response.body)['results']; // 検索したキーワードに該当の店舗を格納
      if (places.isNotEmpty) {
        var firstPlace = places.first;
        var placeId = firstPlace['place_id'];
        await getPlaceDetails(placeId);
      }
    } else {
      print('Failed to search places: ${response.statusCode}');
    }
  }

  // 設定時間おきに近くの店舗検索を実行
  void _startSearchTimer() {
    // const fiveMinutes = Duration(minutes: 5);
    const fiveMinutes = Duration(milliseconds: 10000);
    Timer.periodic(fiveMinutes, (timer) {
      _searchNearbyPlaces();
    });
  }

  // 登録ワードから5キロ以内の近くの店舗を検索
  Future<void> _searchNearbyPlaces() async {
    for (var search in searchList) {
      var url =
          'https://maps.googleapis.com/maps/api/place/textsearch/json?query=${search}&location=${latitude},${longitude}&radius=5000&key=${ApiConfig.googlePlacesApiKey}';

      var response = await http.get(Uri.parse(url));
      print(response);

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        List<dynamic> places = json['results']; // 検索結果jsonデータ
        List<dynamic> newPlaces = []; // 検索にヒットした5キロ以内の店舗

        for (var place in places) {
          // 検索結果から経度・緯度を取得
          var placeLocation = place['geometry']['location'];
          double placeLat = placeLocation['lat'];
          double placeLng = placeLocation['lng'];
          print('--------------------------------------------');
          print(
              "${place['geometry']['location']}, ${placeLocation['lat']}, ${placeLocation['lng']}");

          // 現在地からの距離を取得
          double distanceInMeters = Geolocator.distanceBetween(
              latitude, longitude, placeLat, placeLng);

          if (distanceInMeters < 5000) {
            // 5キロ以内の場合、店舗を追加
            place['distance'] = distanceInMeters;
            newPlaces.add(place);
          }
        }

        // 距離が近い順に並べ替え
        newPlaces.sort((a, b) => a['distance'].compareTo(b['distance']));

        if (newPlaces.isNotEmpty) {
          localNotification.showNotificationTest();
        }
      } else {
        print('Failed to fetch nearby places');
      }
    }
  }

  //
  Future<void> getPlaceDetails(String placeId) async {
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var location =
          jsonDecode(response.body)['result']['geometry']['location'];
      var latitude = location['lat'];
      var longitude = location['lng'];
      print('Latitude: $latitude, Longitude: $longitude');
    } else {
      print('Failed to get place details: ${response.statusCode}');
    }
  }

  Future<void> getNear5kirometers(
      places, double latitude, double longitude) async {
    for (var place in places) {
      var placeLocation = place['geometry']['location'];
      double placeLat = placeLocation['lat'];
      double placeLng = placeLocation['lng'];

      double distanceInMeters =
          Geolocator.distanceBetween(latitude, longitude, placeLat, placeLng);

      if (distanceInMeters < 5000) {
        nearbyPlaces.add(place);
      }
    }
  }

  // 位置情報取得を開始する
  Future myPositionListening() async {
    await Geolocator.requestPermission();
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream().listen((position) {
      // 5分おきに登録ワードにヒットする店舗がないかチェックし、出てきたらローカルプッシュ通知
      _startSearchTimer();

      // 起動時現在地が前橋駅より1キロ以内でプッシュ通知
      if (isWithin1Kilometer(position.latitude, position.longitude)) {
        localNotification.showNotificationTest();
      }

      // お店の位置
      const double shopLat = 35.681167;
      const double shopLon = 139.767052;

      // 現在地とお店の距離を計算する
      double distanceInMeters = Geolocator.distanceBetween(
          position.latitude, position.longitude, shopLat, shopLon);

      // 監視時1km以内に入った際に通知を送る
      if (distanceInMeters <= 1000) {
        localNotification.showNotification();
      }
    });
  }

  // 1キロ以内か判定するメソッド
  bool isWithin1Kilometer(double latitude, double longitude) {
    // 前橋駅の位置
    var shopLatitude = 36.453056;
    var shopLongitude = 139.077171;

    // 現在地と前橋駅の距離を計算
    var distanceInMeters = Geolocator.distanceBetween(
        latitude, longitude, shopLatitude, shopLongitude);
    return distanceInMeters < 1000;
  }
}

final googlePlacesService = GooglePlacesService();
