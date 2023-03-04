import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ShopIndex extends StatefulWidget {
  const ShopIndex({super.key});

  @override
  State<ShopIndex> createState() => _ShopIndexState();
}

class _ShopIndexState extends State<ShopIndex> {
  late StreamSubscription<Position> _positionStreamSubscription;
  late Position _currentPosition;

  @override
  void initState() {
    super.initState();

    // // 現在地を取得するStreamを作成
    // var locationOptions = LocationOptions(
    //     accuracy: LocationAccuracy.best,
    //     distanceFilter: 1
    // );
    // _positionStreamSubscription = Geolocator.getPositionStream(locationOptions).listen((Position position) {
    //   // 現在地を更新
    //   setState(() {
    //     _currentPosition = position;
    //   });

    //   // 1キロ以内になった場合に通知する
    //   if (_currentPosition != null && isWithin1Kilometer(position.latitude, position.longitude)) {
    //     showNotification();
    //   }
    // });
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final inTermSize = constraints.maxWidth / 100 / 4;
      // 端末依存サイズ
      double termSize(double num) {
        final conversionSize = num * 0.0025;
        final terminalMatch = constraints.maxWidth * conversionSize;
        return terminalMatch;
      }

      return Center(
        child: Column(
          children: [
            // Text(_currentPosition?.toString() ?? 'Loading...'),
            Container(
              padding: EdgeInsets.all(inTermSize * 10),
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              color: Colors.white,
              child: const NowLocation(),
            ),
          ],
        ),
      );
    });
  }
}

class NowLocation extends StatefulWidget {
  const NowLocation({Key? key}) : super(key: key);

  @override
  _NowLocationState createState() => _NowLocationState();
}

class _NowLocationState extends State<NowLocation> {
  String _latitude = "NoData";         // 緯度
  String _longitude = "NoData";        // 経度
  String _altitude = "NoData";         // 高度
  String _distanceInMeters = "NoData"; // 距離
  String _bearing = "NoData";          // 方位

  Future<void> getLocation() async {
    // 端末へのアクセス権限を取得
    LocationPermission permission = await Geolocator.requestPermission();
    // 端末へのアクセス権限がない場合は戻る
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    // 位置情報を取得
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latitude =
          "緯度: ${position.latitude.toStringAsFixed(2)}"; // 北緯がプラス、南緯がマイナス
      _longitude =
          "経度: ${position.longitude.toStringAsFixed(2)}"; // 東経がプラス、西経がマイナス
      _altitude = "高度: ${position.altitude.toStringAsFixed(2)}"; // 高度
      // 距離を1000で割ってkmで返す(サンパウロとの距離)
      _distanceInMeters =
          "距離:${(Geolocator.distanceBetween(position.latitude, position.longitude, -23.61, -46.40) / 1000).toStringAsFixed(2)}";
      // 方位を返す(サンパウロとの方位)
      _bearing =
          "方位: ${(Geolocator.bearingBetween(position.latitude, position.longitude, -23.61, -46.40)).toStringAsFixed(2)}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_latitude, style: Theme.of(context).textTheme.headlineMedium),
        Text(_longitude, style: Theme.of(context).textTheme.headlineMedium),
        Text(_altitude, style: Theme.of(context).textTheme.headlineMedium),
        Text(_distanceInMeters,
            style: Theme.of(context).textTheme.headlineMedium),
        Text(_bearing, style: Theme.of(context).textTheme.headlineMedium),
        FloatingActionButton(
            onPressed: getLocation, child: const Icon(Icons.location_on)),
      ],
    );
  }
}
