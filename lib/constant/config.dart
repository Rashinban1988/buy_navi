/*
* Copyright 2023 
*
* buyナビシステム 設定ファイル
* DBから取得できない設定値をここに保持
*
* 分かりやすい変数名、コメントは率先して記載すること。
*/

class ConfigConstant {
  static final ConfigConstant _singleton = ConfigConstant._internal();

  ConfigConstant._internal();

  factory ConfigConstant() {
    return _singleton;
  }

  static const String version = '1.0.0'; // アプリバージョン
}

final configConstant = ConfigConstant();
