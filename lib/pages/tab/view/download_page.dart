import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/item/download_item.dart';
import 'package:fehviewer/pages/tab/controller/download_view_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';

const Color _kDefaultNavBarBorderColor = Color(0x4D000000);

const Border _kDefaultNavBarBorder = Border(
  bottom: BorderSide(
    color: _kDefaultNavBarBorderColor,
    width: 0.2, // One physical pixel.
    style: BorderStyle.solid,
  ),
);

class DownloadTab extends GetView<DownloadViewController> {
  const DownloadTab({Key key, this.tabIndex, this.scrollController})
      : super(key: key);
  final String tabIndex;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final String _title = S.of(context).tab_download;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Obx(
          () => CupertinoSlidingSegmentedControl<DownloadType>(
            children: <DownloadType, Widget>{
              DownloadType.gallery: Text(
                S.of(context).tab_gallery,
                style: const TextStyle(fontSize: 14),
              ).marginSymmetric(horizontal: 6),
              DownloadType.archiver: Text(
                S.of(context).p_Archiver,
                style: const TextStyle(fontSize: 14),
              ).marginSymmetric(horizontal: 6),
            },
            groupValue: controller.viewType ?? DownloadType.gallery,
            onValueChanged: (DownloadType value) {
              controller.viewType = value;
            },
          ),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverSafeArea(
              top: false,
              sliver: SliverFillRemaining(
                child: PageView(
                  controller: controller.pageController,
                  onPageChanged: controller.handOnPageChange,
                  children: <Widget>[
                    DownloadGalleryView(),
                    DownloadArchiverView(),
                  ],
                ),
              ), // sliver: _getGalleryList(),
            ),
          ],
        ),
      ),
    );
  }
}

class DownloadArchiverView extends GetView<DownloadViewController> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (_, int index) {
        final DownloadTaskInfo _taskInfo = controller.archiverTasks[index];

        return GetBuilder<DownloadController>(
            init: DownloadController(),
            id: _taskInfo.tag,
            builder: (DownloadController dowloadController) {
              return GestureDetector(
                onLongPress: () => controller.onLongPress(index),
                behavior: HitTestBehavior.opaque,
                child: DownloadArchiverItem(
                  title: _taskInfo.title ?? '',
                  progress: _taskInfo.progress ?? 0,
                  status: DownloadTaskStatus(_taskInfo.status ?? 0),
                  index: index,
                ),
              );
            });
      },
      separatorBuilder: (_, __) {
        return Divider(
          indent: 20,
          height: 0.6,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey4, context),
        );
      },
      itemCount: controller.archiverTasks.length,
    );
  }
}

class DownloadGalleryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: const Text(
        '[ G ]',
        style: TextStyle(fontSize: 50),
      ),
    );
  }
}
