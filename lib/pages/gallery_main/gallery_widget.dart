import 'package:cached_network_image/cached_network_image.dart';
import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/galleryItem.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery_detail/comment_item.dart';
import 'package:fehviewer/pages/gallery_detail/gallery_all_preview_page.dart';
import 'package:fehviewer/pages/gallery_detail/gallery_detail_widget.dart';
import 'package:fehviewer/pages/gallery_main/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery_main/gallery_favcat.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/values/const.dart';
import 'package:fehviewer/values/theme_colors.dart';
import 'package:fehviewer/widget/rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const double kHeightPreview = 180.0;
const double kPadding = 12.0;

const double kHeaderHeight = 200.0;
const double kHeaderPaddingTop = 12.0;

class GalleryHeader extends StatelessWidget {
  const GalleryHeader({
    Key key,
    @required this.galleryItem,
    @required this.tabIndex,
  }) : super(key: key);

  final GalleryItem galleryItem;
  final Object tabIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(kPadding),
      child: Column(
        children: <Widget>[
          Container(
            height: kHeaderHeight,
            child: Row(
              children: <Widget>[
                // 封面
                CoverImage(
                  imageUrl: galleryItem.imgUrl,
                  heroTag:
                      '${galleryItem.gid}_${galleryItem.token}_cover_$tabIndex',
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 标题
                      GalleryTitle(gid: galleryItem.gid),
                      // 上传用户
                      GalleryUploader(uploader: galleryItem.uploader),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const <Widget>[
                          // 阅读按钮
                          ReadButton(),
                          Spacer(),
                          // 收藏按钮
                          GalleryFavButton(),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              // ignore: prefer_const_literals_to_create_immutables
              children: <Widget>[
                // 评分
                GalleryRating(rating: galleryItem.rating),
                const Spacer(),
                // 类型
                GalleryCategory(category: galleryItem.category),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 封面小图 纯StatelessWidget
class CoveTinyImage extends StatelessWidget {
  const CoveTinyImage({Key key, this.imgUrl, this.statusBarHeight})
      : super(key: key);

  final String imgUrl;
  final double statusBarHeight;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> _httpHeaders = {
      'Cookie': Global.profile?.user?.cookie ?? '',
    };
    return Container(
      padding: const EdgeInsets.all(4),
      child: ClipRRect(
        // 圆角
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          httpHeaders: _httpHeaders,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          imageUrl: imgUrl,
        ),
      ),
    );
  }
}

// 画廊封面
class CoverImage extends StatelessWidget {
  const CoverImage({
    Key key,
    @required this.imageUrl,
    this.heroTag,
    this.imgHeight,
    this.imgWidth,
  }) : super(key: key);

  static const double kWidth = 145.0;
  final String imageUrl;

  // ${_item.gid}_${_item.token}_cover_$_tabIndex
  final Object heroTag;

  final double imgHeight;
  final double imgWidth;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (_) {
      final Map<String, String> _httpHeaders = {
        'Cookie': Global.profile?.user?.cookie ?? '',
      };

      if (imageUrl != null && imageUrl.isNotEmpty) {
        return Container(
          width: kWidth,
          margin: const EdgeInsets.only(right: 10),
          child: Center(
            child: Hero(
              tag: heroTag,
              child: Container(
                decoration: BoxDecoration(boxShadow: [
                  //阴影
                  BoxShadow(
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey4, context),
                    blurRadius: 10,
                  )
                ]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: imgHeight,
                    width: imgWidth,
                    color: CupertinoColors.systemBackground,
                    child: CachedNetworkImage(
                      placeholder: (_, __) {
                        return Container(
                          color: CupertinoDynamicColor.resolve(
                              CupertinoColors.systemGrey5, context),
                        );
                      },
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      httpHeaders: _httpHeaders,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        return Container(
          width: kWidth,
          margin: const EdgeInsets.only(right: 10),
          child: Container(
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(6.0), //圆角
                    // ignore: prefer_const_literals_to_create_immutables
                    boxShadow: [
                  //阴影
                  const BoxShadow(
                    color: CupertinoColors.systemGrey2,
                    blurRadius: 2.0,
                  )
                ]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                color: CupertinoColors.systemBackground,
              ),
            ),
          ),
        );
      }
    });
  }
}

class GalleryTitle extends StatelessWidget {
  const GalleryTitle({
    Key key,
    @required this.gid,
  }) : super(key: key);

  final String gid;

  @override
  Widget build(BuildContext context) {
    final GalleryItemController _itemController = Get.find(tag: gid);

    /// 构建标题
    ///
    /// 问题 文字如果使用 SelectableText 并且页面拉到比较下方的时候
    /// 在返回列表时会异常 疑似和封面图片的Hero动画有关
    /// 如果修改封面图片的 Hero tag ,即不使用 Hero 动画
    /// 异常则不会出现
    ///
    /// 暂时放弃使用 SelectableText
    final GalleryItem galleryItem = _itemController.galleryItem;

    return GestureDetector(
      child: Text(
        _itemController.title,
        maxLines: 5,
        textAlign: TextAlign.left, // 对齐方式
        overflow: TextOverflow.ellipsis, // 超出部分省略号
        style: const TextStyle(
          textBaseline: TextBaseline.alphabetic,
          height: 1.2,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// 上传用户
class GalleryUploader extends StatelessWidget {
  const GalleryUploader({
    Key key,
    @required this.uploader,
  }) : super(key: key);

  final String uploader;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(top: 8, right: 8, bottom: 4),
        child: Text(
          uploader ?? '',
          maxLines: 1,
          textAlign: TextAlign.left, // 对齐方式
          overflow: TextOverflow.ellipsis, // 超出部分省略号
          style: TextStyle(
            fontSize: 13,
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.secondaryLabel, context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      onTap: () {
        logger.v('search uploader:$uploader');
        NavigatorUtil.goGalleryListBySearch(simpleSearch: 'uploader:$uploader');
      },
    );
  }
}

class ReadButton extends StatelessWidget {
  const ReadButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GalleryPageController _pageController = Get.find();
    return Obx(
      () => CupertinoButton(
          child: Text(
            S.of(context).READ,
            style: const TextStyle(fontSize: 15),
          ),
          minSize: 20,
          padding: const EdgeInsets.fromLTRB(15, 2.5, 15, 2.5),
          borderRadius: BorderRadius.circular(50),
          color: CupertinoColors.activeBlue,
          onPressed: _pageController.enableRead ?? false
              ? () => _toViewPage(_pageController)
              : null),
    );
  }

  Future<void> _toViewPage(GalleryPageController _pageController) async {
    final GalleryCacheController galleryCacheController = Get.find();

    final GalleryCache _galleryCache =
        galleryCacheController.getGalleryCache(_pageController.galleryItem.gid);
    final int _index = _galleryCache?.lastIndex ?? 0;
    logger.d('lastIndex $_index');
    await _pageController.showLoadingDialog(Get.context, _index);
    NavigatorUtil.goGalleryViewPage(_index);
  }
}

/// 类别 点击可跳转搜索
class GalleryCategory extends StatelessWidget {
  const GalleryCategory({
    Key key,
    this.category,
  }) : super(key: key);

  final String category;

  @override
  Widget build(BuildContext context) {
    final Color _colorCategory = CupertinoDynamicColor.resolve(
        ThemeColors.catColor[category ?? 'default'], context);
    return GestureDetector(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
          color: _colorCategory,
          child: Text(
            category ?? '',
            style: const TextStyle(
              fontSize: 14.5,
              // height: 1.1,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ),
      onTap: () {
        final int iCat = EHConst.cats[category];
        final int cats = EHConst.sumCats - iCat;
        NavigatorUtil.goGalleryList(cats: cats);
      },
    );
  }
}

class GalleryRating extends StatelessWidget {
  const GalleryRating({
    Key key,
    this.rating,
  }) : super(key: key);

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
            padding: const EdgeInsets.only(right: 8), child: Text('$rating')),
        // 星星
        StaticRatingBar(
          size: 18.0,
          rate: rating ?? 0,
          radiusRatio: 1.5,
        ),
      ],
    );
  }
}

class GalleryDetailInfo extends StatelessWidget {
  GalleryDetailInfo({Key key, this.galleryItem}) : super(key: key);

  final GalleryItem galleryItem;

  final GalleryPageController _pageController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
//        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // 标签
          TagBox(
            listTagGroup: galleryItem.tagGroup,
          ),
          TopComment(comment: galleryItem.galleryComment),
          Divider(
            height: 0.5,
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey4, context),
          ),
          PreviewGrid(previews: _pageController.firstPagePreview),
          _buildAllPreviewButton(),
        ],
      ),
    );
  }

  CupertinoButton _buildAllPreviewButton() {
    return CupertinoButton(
      minSize: 0,
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 30),
      child: Text(
        _pageController.hasMorePreview
            ? S.of(Get.context).morePreviews
            : S.of(Get.context).noMorePreviews,
        style: const TextStyle(fontSize: 16),
      ),
      onPressed: () {
        Get.to(const AllPreviewPage(), transition: Transition.cupertino);
      },
    );
  }

  Widget _buildPreviewGrid() {
    return Builder(builder: (_) {
      final List<GalleryPreview> previews = _pageController.firstPagePreview;
      return GridView.builder(
          padding: const EdgeInsets.only(
              top: kPadding, right: kPadding, left: kPadding),
          shrinkWrap: true,
          //解决无限高度问题
          physics: const NeverScrollableScrollPhysics(),
          //禁用滑动事件
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//              crossAxisCount: _crossAxisCount, //每行列数
              maxCrossAxisExtent: 130,
              mainAxisSpacing: 0, //主轴方向的间距
              crossAxisSpacing: 4, //交叉轴方向子元素的间距
              childAspectRatio: 0.55 //显示区域宽高
              ),
          itemCount: previews.length,
          itemBuilder: (context, index) {
            return Center(
              child: PreviewContainer(
                galleryPreviewList: previews,
                index: index,
              ),
            );
          });
    });
  }
}

class PreviewGrid extends StatelessWidget {
  const PreviewGrid({Key key, this.previews}) : super(key: key);
  final List<GalleryPreview> previews;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        padding: const EdgeInsets.only(
            top: kPadding, right: kPadding, left: kPadding),
        shrinkWrap: true,
        //解决无限高度问题
        physics: const NeverScrollableScrollPhysics(),
        //禁用滑动事件
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//              crossAxisCount: _crossAxisCount, //每行列数
            maxCrossAxisExtent: 130,
            mainAxisSpacing: 0, //主轴方向的间距
            crossAxisSpacing: 4, //交叉轴方向子元素的间距
            childAspectRatio: 0.55 //显示区域宽高
            ),
        itemCount: previews.length,
        itemBuilder: (context, index) {
          return Center(
            child: PreviewContainer(
              galleryPreviewList: previews,
              index: index,
            ),
          );
        });
    ;
  }
}

class TopComment extends StatelessWidget {
  const TopComment({Key key, @required this.comment}) : super(key: key);
  final List<GalleryComment> comment;

  @override
  Widget build(BuildContext context) {
    // 显示最前面两条
    List<Widget> _topComment(List<GalleryComment> comments, {int max = 2}) {
      final Iterable<GalleryComment> _comments = comments.take(max);
      return List<Widget>.from(_comments
          .map((GalleryComment comment) => CommentItem(
                galleryComment: comment,
                simple: true,
              ))
          .toList());
    }

    return Column(
      children: <Widget>[
        // 评论
        GestureDetector(
          onTap: () => NavigatorUtil.goGalleryDetailComment(comment),
          child: Column(
            children: <Widget>[
              ..._topComment(comment, max: 2),
            ],
          ),
        ),
        // 评论按钮
        CupertinoButton(
          minSize: 0,
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Text(
            S.of(Get.context).all_comment,
            style: const TextStyle(fontSize: 16),
          ),
          onPressed: () {
            NavigatorUtil.goGalleryDetailComment(comment);
          },
        ),
      ],
    );
  }
}

/// 包含多个 TagGroup
class TagBox extends StatelessWidget {
  const TagBox({Key key, @required this.listTagGroup}) : super(key: key);

  final List<TagGroup> listTagGroup;

  @override
  Widget build(BuildContext context) {
    final List<Widget> listGroupWidget = <Widget>[];
    for (final TagGroup tagGroupData in listTagGroup) {
      listGroupWidget.add(TagGroupItem(tagGroupData: tagGroupData));
    }

    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.fromLTRB(
              kPadding, kPadding / 2, kPadding, kPadding / 2),
          child: Column(children: listGroupWidget),
        ),
        Container(
          height: 0.5,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey4, Get.context),
        ),
      ],
    );
  }
}

class MorePreviewButton extends StatelessWidget {
  const MorePreviewButton({
    Key key,
    @required this.hasMorePreview,
  }) : super(key: key);

  final bool hasMorePreview;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 0,
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 30),
      child: Text(
        hasMorePreview
            ? S.of(Get.context).morePreviews
            : S.of(Get.context).noMorePreviews,
        style: const TextStyle(fontSize: 16),
      ),
      onPressed: () {
        Get.to(const AllPreviewPage(), transition: Transition.cupertino);
      },
    );
  }
}