import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/tab/view/download_page.dart';
import 'package:fehviewer/pages/tab/view/history_page.dart';
import 'package:fehviewer/pages/tab/view/watched_page.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/store/gallery_store.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../view/favorite_page.dart';
import '../view/gallery_page.dart';
import '../view/popular_page.dart';
import '../view/setting_page.dart';

const double kIconSize = 24.0;
final TabPages tabPages = TabPages();

class TabPages {
  final Map<String, ScrollController> scrollControllerMap = {};
  ScrollController _scrollController(String key) {
    if (scrollControllerMap[key] == null) {
      scrollControllerMap[key] = ScrollController();
    }
    return scrollControllerMap[key];
  }

  Map<String, Widget> get tabViews => <String, Widget>{
        EHRoutes.popular: PopularListTab(
          tabTag: EHRoutes.popular,
          scrollController: _scrollController(EHRoutes.popular),
        ),
        EHRoutes.watched: WatchedListTab(
          tabIndex: EHRoutes.watched,
          scrollController: _scrollController(EHRoutes.watched),
        ),
        EHRoutes.gallery: GalleryListTab(
          tabTag: EHRoutes.gallery,
          scrollController: _scrollController(EHRoutes.gallery),
        ),
        EHRoutes.favorite: FavoriteTab(
          tabTag: EHRoutes.favorite,
          scrollController: _scrollController(EHRoutes.favorite),
        ),
        EHRoutes.history: HistoryTab(
          tabTag: EHRoutes.history,
          scrollController: _scrollController(EHRoutes.history),
        ),
        EHRoutes.download: DownloadTab(
          tabIndex: EHRoutes.download,
          scrollController: _scrollController(EHRoutes.download),
        ),
        EHRoutes.setting: SettingTab(
          tabIndex: EHRoutes.setting,
          scrollController: _scrollController(EHRoutes.setting),
        ),
      };

  final Map<String, IconData> iconDatas = <String, IconData>{
    EHRoutes.popular: FontAwesomeIcons.fire,
    EHRoutes.watched: FontAwesomeIcons.eye,
    EHRoutes.gallery: FontAwesomeIcons.list,
    EHRoutes.favorite: FontAwesomeIcons.solidHeart,
    EHRoutes.history: FontAwesomeIcons.history,
    EHRoutes.download: FontAwesomeIcons.download,
    EHRoutes.setting: FontAwesomeIcons.cog,
  };

  Map<String, Widget> get tabIcons => iconDatas
      .map((key, value) => MapEntry(key, Icon(value, size: kIconSize)));

  Map<String, String> get tabTitles => <String, String>{
        EHRoutes.popular:
            S.of(Get.find<TabHomeController>().tContext).tab_popular,
        EHRoutes.watched:
            S.of(Get.find<TabHomeController>().tContext).tab_watched,
        EHRoutes.gallery:
            S.of(Get.find<TabHomeController>().tContext).tab_gallery,
        EHRoutes.favorite:
            S.of(Get.find<TabHomeController>().tContext).tab_favorite,
        EHRoutes.history:
            S.of(Get.find<TabHomeController>().tContext).tab_history,
        EHRoutes.download:
            S.of(Get.find<TabHomeController>().tContext).tab_download,
        EHRoutes.setting:
            S.of(Get.find<TabHomeController>().tContext).tab_setting,
      };
}

const Map<String, bool> kDefTabMap = <String, bool>{
  EHRoutes.popular: true,
  EHRoutes.watched: true,
  EHRoutes.gallery: true,
  EHRoutes.favorite: true,
  EHRoutes.download: false,
  EHRoutes.history: false,
};

const List<String> kTabNameList = <String>[
  EHRoutes.popular,
  EHRoutes.watched,
  EHRoutes.gallery,
  EHRoutes.favorite,
  EHRoutes.download,
  EHRoutes.history,
];

class TabHomeController extends GetxController {
  DateTime lastPressedAt; //上次点击时间

  int currentIndex = 0;
  bool tapAwait = false;

  final EhConfigService _ehConfigService = Get.find();
  final GStore gStore = Get.find();
  bool get isSafeMode => _ehConfigService.isSafeMode.value;

  final CupertinoTabController tabController = CupertinoTabController();

  // 需要显示的tab
  List<String> get _showTabs => isSafeMode
      ? <String>[
          EHRoutes.gallery,
          EHRoutes.setting,
        ]
      : _sortedTabList;

  List<String> get _sortedTabList {
    final List<String> _list = <String>[];
    for (final String key in tabNameList) {
      if (tabMap[key] ?? false) {
        _list.add(key);
      }
    }
    // end
    _list.add(EHRoutes.setting);
    return _list;
  }

  // 控制tab项顺序
  RxList<String> tabNameList =
      kDefTabMap.entries.map((e) => e.key).toList().obs;

  // 通过控制该变量控制tab项的开关
  RxMap<String, bool> tabMap = kDefTabMap.obs;

  TabConfig _tabConfig;

  @override
  void onInit() {
    super.onInit();

    _tabConfig = gStore.tabConfig ?? (TabConfig()..tabItemList = <TabItem>[]);

    // logger.i('get tab config ${_tabConfig.tabItemList.length}');

    if (_tabConfig.tabMap.isNotEmpty) {
      if (_tabConfig.tabItemList.length < kTabNameList.length) {
        final List<String> _tabConfigNames =
            _tabConfig.tabItemList.map((e) => e.name).toList();
        final List<String> _newTabs = kTabNameList
            .where((String element) => !_tabConfigNames.contains(element))
            .toList();

        // 新增tab页的处理
        logger.d('add tab $_newTabs');

        _newTabs.forEach((String element) {
          _tabConfig.tabItemList.add(TabItem()
            ..name = element
            ..enable = false);
        });
      }

      tabMap(_tabConfig.tabMap);
      if (!Global.inDebugMode) {
        tabMap.remove(EHRoutes.download);
      }
    }

    if (_tabConfig.tabNameList.isNotEmpty) {
      _tabConfig.tabNameList
          .removeWhere((element) => element == EHRoutes.setting);
      tabNameList(_tabConfig.tabNameList);
    }

    // logger.d('${tabNameList}');

    ever(tabMap, (map) {
      _tabConfig.setItemList(map, tabNameList);
      gStore.tabConfig = _tabConfig;
      logger.d(
          '${_tabConfig.tabItemList.map((e) => '${e.name}:${e.enable}').toList().join('\n')}');
    });

    ever(tabNameList, (nameList) {
      _tabConfig.setItemList(tabMap, nameList);
      gStore.tabConfig = _tabConfig;
      logger.d(
          '${_tabConfig.tabItemList.map((e) => '${e.name}:${e.enable}').toList().join('\n')}');
    });
  }

  List<BottomNavigationBarItem> get listBottomNavigationBarItem => _showTabs
      .map((e) => BottomNavigationBarItem(
          icon: tabPages.tabIcons[e], label: tabPages.tabTitles[e]))
      .toList();

  BuildContext tContext = Get.context;

  /// 需要初始化获取BuildContext 否则修改语言时tabitem的文字不会立即生效
  void init({BuildContext inContext}) {
    // logger.d(' rebuild home');
    tContext = inContext;
  }

  List<Widget> get viewList =>
      _showTabs.map((e) => tabPages.tabViews[e]).toList();

  List<ScrollController> get scrollControllerList =>
      _showTabs.map((e) => tabPages.scrollControllerMap[e]).toList();

  Future<void> onTap(int index) async {
    if (index == currentIndex &&
        index != listBottomNavigationBarItem.length - 1) {
      await doubleTapBar(
        duration: const Duration(milliseconds: 800),
        awaitComplete: false,
        onTap: () {
          scrollControllerList[index].animateTo(0.0,
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
        },
        onDoubleTap: () {
          scrollControllerList[index].animateTo(-100.0,
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
        },
      );
    } else {
      currentIndex = index;
    }
  }

  void resetIndex() {
    final int last = listBottomNavigationBarItem.length;
    tabController.index = last - 1;
  }

  /// 双击bar的处理
  Future<void> doubleTapBar(
      {VoidCallback onTap,
      VoidCallback onDoubleTap,
      Duration duration,
      bool awaitComplete}) async {
    final Duration _duration = duration ?? const Duration(milliseconds: 500);
    if (!tapAwait || tapAwait == null) {
      tapAwait = true;

      if (awaitComplete ?? false) {
        await Future<void>.delayed(_duration);
        if (tapAwait) {
//        loggerNoStack.v('等待结束 执行单击事件');
          tapAwait = false;
          onTap();
        }
      } else {
        onTap();
        await Future<void>.delayed(_duration);
        tapAwait = false;
      }
    } else if (onDoubleTap != null) {
//      loggerNoStack.v('等待时间内第二次点击 执行双击事件');
      tapAwait = false;
      onDoubleTap();
    }
  }

  /// 连按两次返回退出
  Future<bool> doubleClickBack() async {
    loggerNoStack.v('click back');
    if (lastPressedAt == null ||
        DateTime.now().difference(lastPressedAt) > const Duration(seconds: 1)) {
      showToast(S.of(tContext).double_click_back);
      //两次点击间隔超过1秒则重新计时
      lastPressedAt = DateTime.now();
      return false;
    }
    return true;
  }
}
