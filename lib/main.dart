import 'package:flutter/src/widgets/app.dart';
import 'package:buy_navi/constant/colors.dart';
import 'package:buy_navi/service/local_notification.dart';
import 'package:buy_navi/ui/coupon_index.dart';
import 'package:buy_navi/ui/menu_index.dart';
import 'package:buy_navi/ui/shop_index.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'service/google_places_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ローカル通知
  localNotification.initLocalNotification(); // ローカル通知初期化
  // localNotification.showNotification(); // 起動時の通知テスト用
  await localNotification.showNotificationTest(); // 起動時の通知テスト用

  // google places API
  // googlePlacesService.searchPlaces('セキチュー'); // キーワードから経度と緯度を取得
  googlePlacesService.myPositionListening(); // 現在地監視前橋駅より1キロ以内でプッシュ通知

  // 縦向き固定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyHomePage(
      title: 'BUY MEMO',
    ));
  });
}

// ページ遷移するための
class Controller extends GetxController {
  var selected = 0.obs;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  // state初期化
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  // state破棄
  @override
  void dispose() {
    debugPrint("dispose");
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // アプリ全体のstate
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("state = $state");
    switch (state) {
      case AppLifecycleState.inactive:
        debugPrint('非アクティブになったときの処理');
        break;
      case AppLifecycleState.paused:
        debugPrint('停止されたときの処理');
        break;
      case AppLifecycleState.resumed:
        // Badges set
        debugPrint('再開されたときの処理');
        break;
      case AppLifecycleState.detached:
        debugPrint('破棄されたときの処理');
        break;
    }
  }

  int selectedpage =0;
  // final _pageNo = [Home() , Favorite() , CartPage() , ProfilePage()];

  final _kPages = <String, FaIcon>{
    '現在地': const FaIcon(FontAwesomeIcons.locationDot),
    'メモ': const FaIcon(FontAwesomeIcons.noteSticky),
    '設定': const FaIcon(FontAwesomeIcons.userGear),
  };

  @override
  Widget build(BuildContext context) {
    final PageController pager = PageController(); // pageViewのコントローラー
    var bottomTabNo = Get.put(Controller()); // pageViewのタブ管理
    return GetMaterialApp(
      // ルート管理
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const MyHomePage(title: 'buy memo',)),
        GetPage(
            name: '/shopIndex',
            page: () => const ShopIndex()),
      ],
      debugShowCheckedModeBanner: false,
      title: 'buy memo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: LayoutBuilder(builder: (context, constraints) {
        final inTermSize = constraints.maxWidth / 100 / 4;
        // 端末依存サイズ
        double termSize(double num) {
          final conversionSize = num * 0.0025;
          final terminalMatch = constraints.maxWidth * conversionSize;
          return terminalMatch;
        }

        return Scaffold(
          body: PageView(
            physics: const NeverScrollableScrollPhysics(), // 横スクロール移動無効
            controller: pager,
            children: const <Widget>[
              ShopIndex(),
              MenuIndex(),
              CouponIndex(),
            ],
            onPageChanged: (int i) {
              bottomTabNo.selected.value = i;
            },
          ),
          bottomNavigationBar: Obx(() => ConvexAppBar(
                style: TabStyle.textIn,
                curveSize: inTermSize * 80, // 丸み
                top: inTermSize * -40, // 丸の高さ
                height: inTermSize * 40, // 横線の高さ
                // cornerRadius: inTermSize * 5, // 角の丸み
                items: const [
                  TabItem(title: '現在地', icon: Icons.home),
                  TabItem(title: 'メモ', icon: Icons.note_alt_rounded),
                  TabItem(title: '設定', icon: Icons.settings),
                ],
                initialActiveIndex: bottomTabNo.selected.value,
                backgroundColor: ColorConstant.bottomBarThemeColor,
                onTap: (int i) {
                  bottomTabNo.selected.value = i;
                  pager.jumpToPage(i);
                },
                curve: Curves.easeOutSine,
              )),
        );
      }),
    );
  }
}
