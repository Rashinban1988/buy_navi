import 'package:flutter/material.dart';

class CouponIndex extends StatelessWidget {
  const CouponIndex({super.key});

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
        child: Container(
          padding: EdgeInsets.all(inTermSize * 10),
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  textAlign: TextAlign.center,
                  'UserSetting',
                  style: TextStyle(
                      fontSize: inTermSize * 18, color: Colors.black87)),
            ],
          ),
        ),
      );
    });
  }
}
