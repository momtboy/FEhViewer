import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery/bindings/gallery_page_binding.dart';
import 'package:fehviewer/pages/gallery/view/gallery_page.dart';
import 'package:fehviewer/pages/tab/controller/gallery_controller.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_page.dart';
import 'package:fehviewer/pages/tab/view/search_page.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigatorUtil {
  /// 转到画廊列表页面
  static void goGalleryList({int cats = 0}) {
    Get.to(const GalleryListTab(),
        binding: BindingsBuilder<GalleryViewController>(() {
      Get.put(GalleryViewController(cats: cats));
    }));
  }

  static void goGalleryListBySearch({
    String simpleSearch,
  }) {
    String _search = simpleSearch;
    if (simpleSearch.contains(':')) {
      final List<String> searArr = simpleSearch.split(':');
      String _end = '';
      if (searArr[0] != 'uploader') {
        _end = '\$';
      }
      _search = '${searArr[0]}:"${searArr[1]}$_end"';
    }

    Get.find<DepthService>().pushSearchPageCtrl();
    Get.to(GallerySearchPage(), transition: Transition.cupertino,
        binding: BindingsBuilder(() {
      Get.lazyPut(
        () => SearchPageController(initSearchText: _search),
        tag: searchPageCtrlDepth,
      );
    }));
  }

  /// 转到画廊页面
  static void goGalleryPage(
      {String url, String tabTag, GalleryItem galleryItem}) {
    Get.find<DepthService>().pushPageCtrl();
    if (url != null && url.isNotEmpty) {
      logger.d('goGalleryPage fromUrl');
      // Get.lazyPut(
      //   () => GalleryRepository(url: url, tabTag: tabTag),
      //   tag: pageCtrlDepth,
      // );

      // Get.toNamed(
      //   EHRoutes.galleryPage,
      //   preventDuplicates: false,
      //   arguments: GalleryRepository(url: url, tabTag: tabTag),
      // );

      Get.to(
        const GalleryMainPage(),
        binding: GalleryBinding(
          galleryRepository: GalleryRepository(url: url, tabTag: tabTag),
        ),
        preventDuplicates: false,
        // arguments: GalleryRepository(url: url, tabTag: tabTag),
      );
    } else {
      logger.d('goGalleryPage fromItem tabTag=$tabTag');

      // Get.lazyPut(
      //   () => GalleryRepository(item: galleryItem, tabTag: tabTag),
      //   tag: pageCtrlDepth,
      // );

      // Get.toNamed(
      //   EHRoutes.galleryPage,
      //   preventDuplicates: false,
      //   arguments: GalleryRepository(item: galleryItem, tabTag: tabTag),
      // );

      Get.to(
        const GalleryMainPage(),
        binding: GalleryBinding(
          galleryRepository:
              GalleryRepository(item: galleryItem, tabTag: tabTag),
        ),
        preventDuplicates: false,
        // arguments: GalleryRepository(item: galleryItem, tabTag: tabTag),
      );
    }
  }

  static void goGalleryDetailReplace(BuildContext context, {String url}) {
    final DepthService depthService = Get.find();
    depthService.pushPageCtrl();
    if (url != null && url.isNotEmpty) {
      // Get.lazyPut(
      //   () => GalleryRepository(url: url),
      //   tag: pageCtrlDepth,
      // );
      // Get.offNamed(EHRoutes.galleryPage,
      //     arguments: GalleryRepository(url: url));
      Get.to(
        const GalleryMainPage(),
        binding: GalleryBinding(
          galleryRepository: GalleryRepository(url: url),
        ),
        preventDuplicates: false,
        // arguments: GalleryRepository(url: url),
      );
    } else {
      Get.to(
        const GalleryMainPage(),
        preventDuplicates: false,
      );
    }
  }

  /// 打开搜索页面 搜索画廊 搜索关注
  static void showSearch({SearchType searchType, bool fromTabItem = true}) {
    logger.d('fromTabItem $fromTabItem');
    Get.to(GallerySearchPage(),
        transition: fromTabItem ? Transition.fadeIn : Transition.cupertino,
        binding: BindingsBuilder(() {
      Get.find<DepthService>().pushSearchPageCtrl();
      Get.lazyPut(
        () => SearchPageController(searchType: searchType),
        tag: searchPageCtrlDepth,
      );
    }));
  }

  // 转到大图浏览
  static void goGalleryViewPage(int index, String gid) {
    // logger.d('goGalleryViewPage $index');
    Get.toNamed(EHRoutes.galleryView, arguments: index);
  }
}
