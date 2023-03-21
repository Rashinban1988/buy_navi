import 'package:buy_navi/ui/todo_add_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MenuIndex extends StatefulWidget {
  const MenuIndex({super.key});

  @override
  State<MenuIndex> createState() => _MenuIndexState();
}

class _MenuIndexState extends State<MenuIndex> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 10));
    // if failed,use refreshFailed()
    Get.to(
      const TodoAddPage(),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 400));
    // setState(() {});
    _refreshController.refreshCompleted();
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

      return Scaffold(
        appBar: AppBar(
          elevation: termSize(0),
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          title: const Text('買い物リスト'),
        ),
        body: SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          header: const ClassicHeader(
              idleText: 'メモを追加', releaseText: '離して', refreshingText: ''),
          child: ListView(
            children: const <Widget>[
              Card(
                child: ListTile(
                  title: Text('たまねぎ'),
                ),
              ),
              Card(
                child: ListTile(
                  title: Text('カレー粉'),
                ),
              ),
              Card(
                child: ListTile(
                  title: Text('たまご'),
                ),
              ),
              Card(
                child: ListTile(
                  title: Text('にんじん'),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
