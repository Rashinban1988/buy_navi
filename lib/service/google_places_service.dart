/*
* Copyright 2023 otomamay. All Rights Reserved.
*/
import 'dart:async';
import 'dart:convert';
import 'package:buy_navi/api_config.dart';
import 'package:buy_navi/service/local_notification.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class GooglePlacesService {
  static final GooglePlacesService _singleton = GooglePlacesService._internal();

  GooglePlacesService._internal();

  factory GooglePlacesService() {
    return _singleton;
  }

  String apiKey = ApiConfig.googlePlacesApiKey; // google places api key
  List<String> searchList = ['富士見中学校', 'ウェルシア']; // 検索ワードリスト
  List<dynamic> nearbyPlaces = [];

  // google Places API で検索ワードから緯度・経度の取得
  Future<dynamic> searchPlaces(searchQuery) async {
    var encodedSearchQuery = Uri.encodeQueryComponent(searchQuery);
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$encodedSearchQuery&key=${ApiConfig.googlePlacesApiKey}');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var places = jsonDecode(response.body)['results']; // 検索したキーワードに該当の店舗を格納
      if (places.isNotEmpty) {
        var fivePlaces = [];
        int i = 0;
        var firstPlace = places.first; // 検索結果１件目取得
        var searchLocation = [];
        for (var place in places) {
          fivePlaces.add(place);
          searchLocation.add(place); // IDから経度・緯度の取得
          if (i == 5) {
            break;
          }
          i++;
        }
        return searchLocation;
      }
    } else {
      debugPrint('Failed to search places: ${response.statusCode}');
    }
  }

  // 経度・緯度の取得
  Future<dynamic> getPlaceDetails(String placeId) async {
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var location =
          jsonDecode(response.body)['result']['geometry']['location'];
      // latitude = 36.35911313;
      // longitude = 139.1208775;
      List<Map<dynamic, dynamic>> searchLocation = [];
      searchLocation.addAll([
        {'latitude': location['lat']},
        {'longitude': location['lng']}
      ]);
      return searchLocation;
    } else {
      debugPrint('Failed to get place details: ${response.statusCode}');
    }
  }

  // 位置情報監視を開始する
  Future myPositionListening() async {
    // var searchLocation = {};
    // searchLocation = await searchPlaces();
    // var shopLatitude = searchLocation['latitude'];
    // var shopLongitude = searchLocation['longitude'];
    // var shopLatitude = 36.3426561;
    // var shopLongitude = 139.1322532;
    var shopLatitude = 37.785834;
    var shopLongitude = -122.406417;
    await Geolocator.requestPermission(); // 位置情報取得の許可確認メッセージ
    // 位置情報監視スタート
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream().listen((position) {
      // 以下位置情報が更新された際に実行する関数を記載
      // 起動時現在地がお店の位置より1キロ以内でプッシュ通知
      if (isWithin1Kilometer(
          position.latitude, position.longitude, shopLatitude, shopLongitude)) {
        localNotification.showNotification();
      }
    });
  }

  // 1キロ以内か判定するメソッド
  bool isWithin1Kilometer(double latitude, double longitude,
      double shopLatitude, double shopLongitude) {
    // 現在地と検索地との距離を計算
    var distanceInMeters = Geolocator.distanceBetween(
        latitude, longitude, shopLatitude, shopLongitude);
    debugPrint('現在地：$latitude(緯度), $longitude(経度)');
    debugPrint('検索地との距離： $distanceInMeters');
    return distanceInMeters < 1000;
  }

  // 1キロ以内か判定するメソッド
  dynamic isWithin1Kilometers(double shopLatitude, double shopLongitude) async {
    var position = await Geolocator.getCurrentPosition();
    // 現在地と検索地との距離を計算
    var distanceInMeters = Geolocator.distanceBetween(
        position.latitude, position.longitude, shopLatitude, shopLongitude);
    return distanceInMeters;
  }
}

final googlePlacesService = GooglePlacesService();
