/*
* Copyright 2023 
*
* buyナビシステム 設定ファイル
* DBから取得できない設定値をここに保持
*
* 分かりやすい変数名、コメントは率先して記載すること。
*/

import 'package:flutter/material.dart';

class ColorConstant {
  static final ColorConstant _singleton = ColorConstant._internal();

  ColorConstant._internal();

  factory ColorConstant() {
    return _singleton;
  }

  static const Color appBarThemeColor =
      Color.fromRGBO(50, 228, 255, 0.898); // appBarカラ
  
  // navigationBottomBar
  static const Color bottomBarThemeColor =
      Color.fromRGBO(36, 162, 111, 0.894); // bottomBarカラー
  static const Color bottomBarFixColor =
      Color.fromRGBO(50, 118, 255, 0.725); // bottomBarFixカラー
}

final colorConstant = ColorConstant();
