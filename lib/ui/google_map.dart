import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/shop.dart';
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

  final _pageController = PageController(
    viewportFraction: 1,//0.85くらいで端っこに別のカードが見えてる感じになる
  );

  final shops = [
    Shop('1', 36.3446996, 139.1242414, 'セキチュー駒形店'),
    Shop('2', 36.3416856, 139.1978572, '華蔵寺遊園地'),
  ];

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
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                _mapSection(),
                _cardSection(),
              ],
            );
          }
          return Container();
        });
  }

  Widget _mapSection() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
      },
      myLocationEnabled: true,
      markers: shops.map(
        (selectedShop) {
          return Marker(
            markerId: MarkerId(selectedShop.uid),
            position: LatLng(selectedShop.latitude, selectedShop.longitude),
            icon: BitmapDescriptor.defaultMarker,
            onTap: () async {
              //タップしたマーカー(shop)のindexを取得
              final index = shops.indexWhere((shop) => shop == selectedShop);
              //タップしたお店がPageViewで表示されるように飛ばす
              _pageController.jumpToPage(index);
            },
          );
        },
      ).toSet(),
    );
  }

  Widget _cardSection() {
    return Container(
      width: 200,
      height: 120,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: PageView(
        onPageChanged: (int index) async {
          //スワイプ後のページのお店を取得
          final selectedShop = shops.elementAt(index);
          //現在のズームレベルを取得
          final zoomLevel = await _controller.getZoomLevel();
          //スワイプ後のお店の座標までカメラを移動
          _controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(selectedShop.latitude, selectedShop.longitude),
                zoom: zoomLevel,
              ),
            ),
          );
        },
        controller: _pageController,
        children: _shopTiles(),
      ),
    );
  }

  //カード1枚1枚について
  List<Widget> _shopTiles() {
    final shopTiles = shops.map(
      (shop) {
        return Card(
          elevation: 10,
          shadowColor: Colors.green,
          surfaceTintColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(
            width: 60,
            height: 20,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.maps_home_work),
                      Text(shop.name),
                    ],
                  ),
                  const ElevatedButton(
                    onPressed: null,
                    child: Text('このお店を登録'))
                ],
              ),
            ),
          ),
        );
      },
    ).toList();
    return shopTiles;
  }
}
