import 'package:buy_navi/ui/google_map.dart';
import 'package:flutter/material.dart';

class CouponIndex extends StatelessWidget {
  const CouponIndex({super.key});

  @override
  Widget build(BuildContext context) {
    final _serchPlaces = [];
    return MapSample(serchPlaces: _serchPlaces);
  }
}
