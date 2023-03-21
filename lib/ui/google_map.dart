import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'loading_display.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  late GoogleMapController _controller;
  late Position position; // 現在地緯度・経度
  double currentLatitude = 0; // 現在地緯度
  double currentLongitude = 0; // 現在地経度
  late CameraPosition _kGooglePlex; // GoogleMaps起動時初期位置
  BitmapDescriptor? _markerIcon;
  final Set<Marker> _markers = {};

  // state初期化
  @override
  void initState() {
    super.initState();
  }

  Marker _createMarker() {
    return Marker(
      markerId: const MarkerId('marker'),
      position: LatLng(position.latitude, position.longitude),
      icon: _markerIcon ?? BitmapDescriptor.defaultMarker,
      infoWindow: const InfoWindow(title: '現在地'),
    );
  }

  Future<bool> getCurrentPosition() async {
    position = await Geolocator.getCurrentPosition();
    currentLatitude = position.latitude;
    currentLongitude = position.longitude;
    //初期位置
    _kGooglePlex = CameraPosition(
      target: LatLng(currentLatitude, currentLongitude),
      zoom: 12,
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getCurrentPosition(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          // 通信中はスピナーを表示
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingDisplay();
          }

          // エラー発生時エラーメッセージ表示
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          // データ取得が完了したら
          if (snapshot.hasData) {
            return GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
              myLocationEnabled: true,
            );
          }
          return Container();
        });
  }
}
